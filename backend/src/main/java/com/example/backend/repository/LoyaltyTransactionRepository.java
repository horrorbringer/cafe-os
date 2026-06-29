package com.example.backend.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import com.example.backend.model.LoyaltyTransactionEntity;
import com.example.backend.model.LoyaltyTransactionEntity.LoyaltyTransactionType;

@Repository
public interface LoyaltyTransactionRepository extends JpaRepository<LoyaltyTransactionEntity, Long> {
    List<LoyaltyTransactionEntity> findTop50ByCustomerCustomerIdAndDeletedAtIsNullOrderByCreatedAtDesc(Long customerId);

    boolean existsByOrderOrderIdAndTypeAndDeletedAtIsNull(Long orderId, LoyaltyTransactionType type);

    @Query("""
            SELECT COALESCE(SUM(t.points), 0)
            FROM LoyaltyTransactionEntity t
            WHERE t.deletedAt IS NULL AND t.type = :type
            """)
    Long sumPointsByType(LoyaltyTransactionType type);

    @Query("""
            SELECT COALESCE(SUM(t.points), 0)
            FROM LoyaltyTransactionEntity t
            WHERE t.deletedAt IS NULL AND t.type = :type AND t.points > 0
            """)
    Long sumPositivePointsByType(LoyaltyTransactionType type);

    @Query("""
            SELECT COALESCE(SUM(t.points), 0)
            FROM LoyaltyTransactionEntity t
            WHERE t.deletedAt IS NULL AND t.type = :type AND t.points < 0
            """)
    Long sumNegativePointsByType(LoyaltyTransactionType type);
}
