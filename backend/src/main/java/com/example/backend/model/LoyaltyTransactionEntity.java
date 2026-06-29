package com.example.backend.model;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Index;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;

@Entity
@Table(name = "tblloyalty_transactions", indexes = {
        @Index(name = "idx_loyalty_customer_id", columnList = "customer_id"),
        @Index(name = "idx_loyalty_order_id", columnList = "order_id"),
        @Index(name = "idx_loyalty_created_at", columnList = "created_at")
})
public class LoyaltyTransactionEntity extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "loyalty_transaction_id")
    private Long loyaltyTransactionId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "customer_id", nullable = false)
    private CustomerEntity customer;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "order_id")
    private OrderEntity order;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private LoyaltyTransactionType type;

    @Column(nullable = false)
    private Integer points;

    @Column(name = "balance_after", nullable = false)
    private Integer balanceAfter;

    @Column(name = "earn_rate")
    private Double earnRate;

    @Column(name = "redeem_rate")
    private Double redeemRate;

    @Column(columnDefinition = "TEXT")
    private String note;

    public enum LoyaltyTransactionType {
        EARN,
        REDEEM,
        REFUND_REDEEM,
        REVERT_EARN,
        ADJUSTMENT
    }

    public Long getLoyaltyTransactionId() {
        return loyaltyTransactionId;
    }

    public void setLoyaltyTransactionId(Long loyaltyTransactionId) {
        this.loyaltyTransactionId = loyaltyTransactionId;
    }

    public CustomerEntity getCustomer() {
        return customer;
    }

    public void setCustomer(CustomerEntity customer) {
        this.customer = customer;
    }

    public OrderEntity getOrder() {
        return order;
    }

    public void setOrder(OrderEntity order) {
        this.order = order;
    }

    public LoyaltyTransactionType getType() {
        return type;
    }

    public void setType(LoyaltyTransactionType type) {
        this.type = type;
    }

    public Integer getPoints() {
        return points;
    }

    public void setPoints(Integer points) {
        this.points = points;
    }

    public Integer getBalanceAfter() {
        return balanceAfter;
    }

    public void setBalanceAfter(Integer balanceAfter) {
        this.balanceAfter = balanceAfter;
    }

    public Double getEarnRate() {
        return earnRate;
    }

    public void setEarnRate(Double earnRate) {
        this.earnRate = earnRate;
    }

    public Double getRedeemRate() {
        return redeemRate;
    }

    public void setRedeemRate(Double redeemRate) {
        this.redeemRate = redeemRate;
    }

    public String getNote() {
        return note;
    }

    public void setNote(String note) {
        this.note = note;
    }
}
