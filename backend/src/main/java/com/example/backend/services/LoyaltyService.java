package com.example.backend.services;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.example.backend.model.CustomerEntity;
import com.example.backend.model.LoyaltyTransactionEntity;
import com.example.backend.model.LoyaltyTransactionEntity.LoyaltyTransactionType;
import com.example.backend.model.OrderEntity;
import com.example.backend.repository.CustomerRepository;
import com.example.backend.repository.LoyaltyTransactionRepository;
import com.example.backend.repository.OrderRepository;

@Service
public class LoyaltyService {

    private final CustomerRepository customerRepository;
    private final OrderRepository orderRepository;
    private final SystemSettingService systemSettingService;
    private final LoyaltyTransactionRepository loyaltyTransactionRepository;

    public LoyaltyService(CustomerRepository customerRepository, OrderRepository orderRepository,
            SystemSettingService systemSettingService,
            LoyaltyTransactionRepository loyaltyTransactionRepository) {
        this.customerRepository = customerRepository;
        this.orderRepository = orderRepository;
        this.systemSettingService = systemSettingService;
        this.loyaltyTransactionRepository = loyaltyTransactionRepository;
    }

    public double getRedeemRate() {
        String rateStr = systemSettingService.getValue("LOYALTY_REDEEM_RATE");
        if (rateStr != null) {
            try {
                return Double.parseDouble(rateStr);
            } catch (NumberFormatException e) {
                // fall back to default
            }
        }
        return 0.1; // Default: 10 points = $1
    }

    public double getEarnRate() {
        String rateStr = systemSettingService.getValue("LOYALTY_EARN_RATE");
        if (rateStr != null) {
            try {
                return Double.parseDouble(rateStr);
            } catch (NumberFormatException e) {
                // fall back to default
            }
        }
        return 1.0; // Default: $1 = 1 point
    }

    @Transactional
    public void awardPoints(OrderEntity order) {
        if (order.getCustomer() == null || order.getStatus() != OrderEntity.OrderStatus.PAID) {
            return;
        }

        CustomerEntity customer = order.getCustomer();
        double earnRate = getEarnRate();
        
        int pointsToGain = (int) Math.floor(order.getTotalAmount() * earnRate);
        if (pointsToGain <= 0) {
            order.setPointsEarned(0);
            saveOrderIfPersisted(order);
            return;
        }
        if (order.getOrderId() != null && loyaltyTransactionRepository.existsByOrderOrderIdAndTypeAndDeletedAtIsNull(
                order.getOrderId(), LoyaltyTransactionType.EARN)) {
            return;
        }

        int currentPoints = customer.getLoyaltyPoints() != null ? customer.getLoyaltyPoints() : 0;
        int balanceAfter = currentPoints + pointsToGain;
        customer.setLoyaltyPoints(balanceAfter);
        order.setPointsEarned(pointsToGain);

        updateMembershipLevel(customer);
        saveOrderIfPersisted(order);
        customerRepository.save(customer);
        recordTransaction(customer, order, LoyaltyTransactionType.EARN, pointsToGain, balanceAfter, earnRate, null,
                "Earned from paid order " + order.getOrderNo());
    }

    @Transactional
    public void revertPoints(OrderEntity order) {
        if (order.getCustomer() == null) return;

        CustomerEntity customer = order.getCustomer();
        int pointsToRemove = order.getPointsEarned() != null ? order.getPointsEarned() : 0;
        if (pointsToRemove <= 0) return;
        if (order.getOrderId() != null && loyaltyTransactionRepository.existsByOrderOrderIdAndTypeAndDeletedAtIsNull(
                order.getOrderId(), LoyaltyTransactionType.REVERT_EARN)) {
            return;
        }

        int currentPoints = customer.getLoyaltyPoints() != null ? customer.getLoyaltyPoints() : 0;
        int balanceAfter = Math.max(0, currentPoints - pointsToRemove);

        customer.setLoyaltyPoints(balanceAfter);
        order.setPointsEarned(0);
        updateMembershipLevel(customer);
        saveOrderIfPersisted(order);
        customerRepository.save(customer);
        recordTransaction(customer, order, LoyaltyTransactionType.REVERT_EARN, -pointsToRemove, balanceAfter, null, null,
                "Reverted earned points for order " + order.getOrderNo());
    }

    @Transactional
    public void deductPoints(CustomerEntity customer, int points) {
        deductPoints(customer, null, points);
    }

    @Transactional
    public void deductPoints(CustomerEntity customer, OrderEntity order, int points) {
        if (customer == null || points <= 0) return;
        if (order != null && order.getOrderId() != null && loyaltyTransactionRepository.existsByOrderOrderIdAndTypeAndDeletedAtIsNull(
                order.getOrderId(), LoyaltyTransactionType.REDEEM)) {
            return;
        }

        int currentPoints = customer.getLoyaltyPoints() != null ? customer.getLoyaltyPoints() : 0;
        int balanceAfter = Math.max(0, currentPoints - points);
        customer.setLoyaltyPoints(balanceAfter);
        updateMembershipLevel(customer);
        customerRepository.save(customer);
        recordTransaction(customer, order, LoyaltyTransactionType.REDEEM, -points, balanceAfter, null, getRedeemRate(),
                order != null ? "Redeemed on order " + order.getOrderNo() : "Redeemed points");
    }

    @Transactional
    public void refundPoints(CustomerEntity customer, int points) {
        refundPoints(customer, null, points);
    }

    @Transactional
    public void refundPoints(CustomerEntity customer, OrderEntity order, int points) {
        if (customer == null || points <= 0) return;
        if (order != null && order.getOrderId() != null && loyaltyTransactionRepository.existsByOrderOrderIdAndTypeAndDeletedAtIsNull(
                order.getOrderId(), LoyaltyTransactionType.REFUND_REDEEM)) {
            return;
        }

        int currentPoints = customer.getLoyaltyPoints() != null ? customer.getLoyaltyPoints() : 0;
        int balanceAfter = currentPoints + points;
        customer.setLoyaltyPoints(balanceAfter);
        updateMembershipLevel(customer);
        customerRepository.save(customer);
        recordTransaction(customer, order, LoyaltyTransactionType.REFUND_REDEEM, points, balanceAfter, null, getRedeemRate(),
                order != null ? "Refunded redeemed points for order " + order.getOrderNo() : "Refunded redeemed points");
    }

    @Transactional
    public CustomerEntity adjustPoints(CustomerEntity customer, int points, String reason) {
        if (customer == null) {
            throw new IllegalArgumentException("Customer is required");
        }
        if (points == 0) {
            throw new IllegalArgumentException("Adjustment must be more or less than 0 points");
        }

        int currentPoints = customer.getLoyaltyPoints() != null ? customer.getLoyaltyPoints() : 0;
        int balanceAfter = Math.max(0, currentPoints + points);
        int appliedPoints = balanceAfter - currentPoints;
        if (appliedPoints == 0) {
            throw new IllegalArgumentException("Adjustment would not change the customer balance");
        }

        customer.setLoyaltyPoints(balanceAfter);
        updateMembershipLevel(customer);
        CustomerEntity savedCustomer = customerRepository.save(customer);
        recordTransaction(savedCustomer, null, LoyaltyTransactionType.ADJUSTMENT, appliedPoints, balanceAfter, null, null,
                "Manual adjustment: " + reason.trim());
        return savedCustomer;
    }

    private void recordTransaction(CustomerEntity customer, OrderEntity order, LoyaltyTransactionType type, int points,
            int balanceAfter, Double earnRate, Double redeemRate, String note) {
        LoyaltyTransactionEntity transaction = new LoyaltyTransactionEntity();
        transaction.setCustomer(customer);
        transaction.setOrder(order);
        transaction.setType(type);
        transaction.setPoints(points);
        transaction.setBalanceAfter(balanceAfter);
        transaction.setEarnRate(earnRate);
        transaction.setRedeemRate(redeemRate);
        transaction.setNote(note);
        loyaltyTransactionRepository.save(transaction);
    }

    private void saveOrderIfPersisted(OrderEntity order) {
        if (order != null && order.getOrderId() != null) {
            orderRepository.save(order);
        }
    }

    private void updateMembershipLevel(CustomerEntity customer) {
        int totalPoints = customer.getLoyaltyPoints() != null ? customer.getLoyaltyPoints() : 0;
        
        int silverThreshold = 300;
        int goldThreshold = 1000;
        
        try {
            String silverVal = systemSettingService.getValue("LOYALTY_SILVER_THRESHOLD");
            if (silverVal != null) silverThreshold = Integer.parseInt(silverVal);
            
            String goldVal = systemSettingService.getValue("LOYALTY_GOLD_THRESHOLD");
            if (goldVal != null) goldThreshold = Integer.parseInt(goldVal);
        } catch (Exception e) {}

        if (totalPoints >= goldThreshold) {
            customer.setMembershipLevel("GOLD");
        } else if (totalPoints >= silverThreshold) {
            customer.setMembershipLevel("SILVER");
        } else {
            customer.setMembershipLevel("BRONZE");
        }
    }
}
