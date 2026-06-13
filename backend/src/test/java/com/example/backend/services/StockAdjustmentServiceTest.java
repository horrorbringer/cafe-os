package com.example.backend.services;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

import java.util.Optional;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import com.example.backend.dto.StockAdjustmentRequestDTO;
import com.example.backend.dto.StockAdjustmentResponseDTO;
import com.example.backend.mapper.StockAdjustmentMapper;
import com.example.backend.model.BranchEntity;
import com.example.backend.model.IngredientEntity;
import com.example.backend.model.StockAdjustmentEntity;
import com.example.backend.model.UserEntity;
import com.example.backend.repository.BranchRepository;
import com.example.backend.repository.IngredientRepository;
import com.example.backend.repository.StockAdjustmentRepository;
import com.example.backend.repository.UserRepository;

@ExtendWith(MockitoExtension.class)
public class StockAdjustmentServiceTest {

    @Mock
    private StockAdjustmentRepository stockAdjustmentRepository;

    @Mock
    private IngredientRepository ingredientRepository;

    @Mock
    private StockAdjustmentMapper stockAdjustmentMapper;

    @Mock
    private UserRepository userRepository;

    @Mock
    private BranchStockService branchStockService;

    @Mock
    private BranchRepository branchRepository;

    @InjectMocks
    private StockAdjustmentService service;

    private IngredientEntity ingredient;
    private UserEntity creator;
    private BranchEntity branch;
    private StockAdjustmentRequestDTO requestDTO;
    private StockAdjustmentEntity entity;
    private StockAdjustmentResponseDTO responseDTO;

    @BeforeEach
    void setUp() {
        ingredient = new IngredientEntity();
        ingredient.setIngredientId(1L);
        ingredient.setName("Milk");
        ingredient.setCurrentStock(10.0);

        creator = new UserEntity();
        creator.setUserId(2L);

        branch = new BranchEntity();
        branch.setBranchId(3L);

        requestDTO = new StockAdjustmentRequestDTO();
        requestDTO.setIngredientId(1L);
        requestDTO.setCreatedBy(2L);
        requestDTO.setBranchId(3L);
        requestDTO.setQtyChange(-2.0); // Wastage
        requestDTO.setReasonType("WASTAGE");

        entity = new StockAdjustmentEntity();
        entity.setAdjustmentId(100L);

        responseDTO = new StockAdjustmentResponseDTO();
        responseDTO.setAdjustmentId(100L);
    }

    @Test
    void createAdjustment_Success_Wastage() {
        when(ingredientRepository.findById(1L)).thenReturn(Optional.of(ingredient));
        when(userRepository.findById(2L)).thenReturn(Optional.of(creator));
        when(branchRepository.findById(3L)).thenReturn(Optional.of(branch));
        when(stockAdjustmentMapper.toEntity(requestDTO)).thenReturn(entity);
        when(stockAdjustmentRepository.save(any(StockAdjustmentEntity.class))).thenReturn(entity);
        when(stockAdjustmentMapper.toResponseDTO(entity)).thenReturn(responseDTO);

        StockAdjustmentResponseDTO result = service.createAdjustment(requestDTO);

        assertNotNull(result);
        assertEquals(10.0, ingredient.getCurrentStock());
        assertEquals(StockAdjustmentEntity.AdjustmentStatus.PENDING, entity.getStatus());

        verifyNoInteractions(branchStockService);
        verify(stockAdjustmentRepository).save(entity);
    }
}
