package com.example.backend.services;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.example.backend.dto.loyalty.LoyaltyBackfillResultDTO;
import com.example.backend.model.CustomerEntity;
import com.example.backend.model.LoyaltyTransactionEntity;
import com.example.backend.model.LoyaltyTransactionEntity.LoyaltyTransactionType;
import com.example.backend.model.OrderEntity;
import com.example.backend.repository.LoyaltyTransactionRepository;
import com.example.backend.repository.OrderRepository;

@Service
public class LoyaltyBackfillService {

    private final OrderRepository orderRepository;
    private final LoyaltyTransactionRepository loyaltyTransactionRepository;
    private final LoyaltyService loyaltyService;

    public LoyaltyBackfillService(OrderRepository orderRepository,
            LoyaltyTransactionRepository loyaltyTransactionRepository,
            LoyaltyService loyaltyService) {
        this.orderRepository = orderRepository;
        this.loyaltyTransactionRepository = loyaltyTransactionRepository;
        this.loyaltyService = loyaltyService;
    }

    @Transactional
    public LoyaltyBackfillResultDTO backfill(Boolean apply) {
        boolean shouldApply = Boolean.TRUE.equals(apply);
        LoyaltyBackfillResultDTO result = new LoyaltyBackfillResultDTO();
        result.setApplied(shouldApply);
        result.setScannedOrders(0);
        result.setEarnTransactionsCreated(0);
        result.setRedeemTransactionsCreated(0);
        result.setSkippedOrders(0);
        result.setNote(shouldApply
                ? "Created missing ledger rows only. Customer balances were not changed."
                : "Preview only. No data was changed.");

        double earnRate = loyaltyService.getEarnRate();
        double redeemRate = loyaltyService.getRedeemRate();

        for (OrderEntity order : orderRepository.findOrdersForLoyaltyBackfill()) {
            result.setScannedOrders(result.getScannedOrders() + 1);
            CustomerEntity customer = order.getCustomer();
            if (customer == null) {
                result.setSkippedOrders(result.getSkippedOrders() + 1);
                continue;
            }

            int balanceSnapshot = customer.getLoyaltyPoints() != null ? customer.getLoyaltyPoints() : 0;
            int earnPoints = order.getPointsEarned() != null && order.getPointsEarned() > 0
                    ? order.getPointsEarned()
                    : (int) Math.floor((order.getTotalAmount() != null ? order.getTotalAmount() : 0.0) * earnRate);
            if (earnPoints > 0 && !hasTransaction(order, LoyaltyTransactionType.EARN)) {
                result.setEarnTransactionsCreated(result.getEarnTransactionsCreated() + 1);
                if (shouldApply) {
                    order.setPointsEarned(earnPoints);
                    orderRepository.save(order);
                    record(customer, order, LoyaltyTransactionType.EARN, earnPoints, balanceSnapshot, earnRate, null,
                            "Backfilled earned points for order " + order.getOrderNo());
                }
            }

            int redeemedPoints = order.getPointsRedeemed() != null ? order.getPointsRedeemed() : 0;
            if (redeemedPoints > 0 && !hasTransaction(order, LoyaltyTransactionType.REDEEM)) {
                result.setRedeemTransactionsCreated(result.getRedeemTransactionsCreated() + 1);
                if (shouldApply) {
                    record(customer, order, LoyaltyTransactionType.REDEEM, -redeemedPoints, balanceSnapshot, null,
                            redeemRate, "Backfilled redeemed points for order " + order.getOrderNo());
                }
            }
        }

        return result;
    }

    private boolean hasTransaction(OrderEntity order, LoyaltyTransactionType type) {
        return order.getOrderId() != null
                && loyaltyTransactionRepository.existsByOrderOrderIdAndTypeAndDeletedAtIsNull(order.getOrderId(), type);
    }

    private void record(CustomerEntity customer, OrderEntity order, LoyaltyTransactionType type, int points,
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
}
