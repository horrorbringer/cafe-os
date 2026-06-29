package com.example.backend.services;

import java.util.List;
import java.util.Map;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.example.backend.model.SystemSettingEntity;
import com.example.backend.model.CustomerEntity;
import com.example.backend.repository.CustomerRepository;
import com.example.backend.repository.SystemSettingRepository;


@Service
public class SystemSettingService {

    private final SystemSettingRepository repository;
    private final CustomerRepository customerRepository;

    public SystemSettingService(SystemSettingRepository repository, CustomerRepository customerRepository) {
        this.repository = repository;
        this.customerRepository = customerRepository;
    }

    public List<SystemSettingEntity> getAllSettings() {
        return repository.findAll();
    }

    public String getValue(String key) {
        return repository.findByKey(key)
                .map(SystemSettingEntity::getValue)
                .orElse(null);
    }

    public SystemSettingEntity updateSetting(String key, String value) {
        SystemSettingEntity setting = repository.findByKey(key)
                .orElseThrow(() -> new RuntimeException("Setting not found: " + key));
        setting.setValue(value);
        return repository.save(setting);
    }
    
    @Transactional
    public void updateSettings(Map<String, String> settings) {
        validateSettings(settings);
        boolean loyaltyThresholdChanged = false;
        for (Map.Entry<String, String> entry : settings.entrySet()) {
            String key = entry.getKey();
            String value = entry.getValue();

            SystemSettingEntity setting = repository.findByKey(entry.getKey())
                .orElse(null);
            
            if (setting != null) {
                setting.setValue(value);
                repository.save(setting);
            } else {
                // Create new setting if it doesn't exist
                SystemSettingEntity newSetting = new SystemSettingEntity();
                newSetting.setKey(key);
                newSetting.setValue(value);
                newSetting.setDescription(defaultDescription(key));
                newSetting.setGroup(defaultGroup(key));
                repository.save(newSetting);
            }

            if ("LOYALTY_SILVER_THRESHOLD".equals(key) || "LOYALTY_GOLD_THRESHOLD".equals(key)) {
                loyaltyThresholdChanged = true;
            }
        }

        if (loyaltyThresholdChanged) {
            recalculateMembershipLevels();
        }
    }

    private void validateSettings(Map<String, String> settings) {
        for (Map.Entry<String, String> entry : settings.entrySet()) {
            String key = entry.getKey();
            String value = entry.getValue();

            if (key == null || key.isBlank()) {
                throw new IllegalArgumentException("Setting key is required");
            }
            if (value == null) {
                throw new IllegalArgumentException("Setting value is required for " + key);
            }

            if ("LOYALTY_EARN_RATE".equals(key) || "LOYALTY_REDEEM_RATE".equals(key)) {
                double parsed = parseDouble(key, value);
                if (parsed <= 0) {
                    throw new IllegalArgumentException(key + " must be greater than 0");
                }
            }

            if ("LOYALTY_SILVER_THRESHOLD".equals(key) || "LOYALTY_GOLD_THRESHOLD".equals(key)) {
                int parsed = parseInt(key, value);
                if (parsed < 0) {
                    throw new IllegalArgumentException(key + " cannot be negative");
                }
            }
        }

        if (settings.containsKey("LOYALTY_SILVER_THRESHOLD") || settings.containsKey("LOYALTY_GOLD_THRESHOLD")) {
            int silver = parseInt("LOYALTY_SILVER_THRESHOLD", settingValue(settings, "LOYALTY_SILVER_THRESHOLD", "300"));
            int gold = parseInt("LOYALTY_GOLD_THRESHOLD", settingValue(settings, "LOYALTY_GOLD_THRESHOLD", "1000"));
            if (silver >= gold) {
                throw new IllegalArgumentException("Gold threshold must be greater than Silver threshold");
            }
        }
    }

    private String settingValue(Map<String, String> settings, String key, String fallback) {
        if (settings.containsKey(key)) return settings.get(key);
        String stored = getValue(key);
        return stored != null ? stored : fallback;
    }

    private double parseDouble(String key, String value) {
        try {
            return Double.parseDouble(value);
        } catch (NumberFormatException e) {
            throw new IllegalArgumentException(key + " must be a valid number");
        }
    }

    private int parseInt(String key, String value) {
        try {
            return Integer.parseInt(value);
        } catch (NumberFormatException e) {
            throw new IllegalArgumentException(key + " must be a valid whole number");
        }
    }

    private String defaultGroup(String key) {
        if (key.startsWith("LOYALTY_")) return "LOYALTY";
        if (key.startsWith("TELEGRAM_") || key.startsWith("NOTIFY_") || "LARGE_ORDER_THRESHOLD".equals(key)) return "NOTIFICATIONS";
        if (key.startsWith("BAKONG_") || "TAX_RATE".equals(key) || "CURRENCY_SYMBOL".equals(key)) return "FINANCE";
        if ("THEME".equals(key)) return "APPEARANCE";
        return "GENERAL";
    }

    private String defaultDescription(String key) {
        return switch (key) {
            case "LOYALTY_EARN_RATE" -> "Points earned per $1 spent";
            case "LOYALTY_REDEEM_RATE" -> "USD discount per 1 point";
            case "LOYALTY_SILVER_THRESHOLD" -> "Points required for Silver tier";
            case "LOYALTY_GOLD_THRESHOLD" -> "Points required for Gold tier";
            default -> key.replace("_", " ");
        };
    }

    private void recalculateMembershipLevels() {
        int silverThreshold = parseInt("LOYALTY_SILVER_THRESHOLD", settingValue(Map.of(), "LOYALTY_SILVER_THRESHOLD", "300"));
        int goldThreshold = parseInt("LOYALTY_GOLD_THRESHOLD", settingValue(Map.of(), "LOYALTY_GOLD_THRESHOLD", "1000"));

        for (CustomerEntity customer : customerRepository.findAll()) {
            int points = customer.getLoyaltyPoints() != null ? customer.getLoyaltyPoints() : 0;
            if (points >= goldThreshold) {
                customer.setMembershipLevel("GOLD");
            } else if (points >= silverThreshold) {
                customer.setMembershipLevel("SILVER");
            } else {
                customer.setMembershipLevel("BRONZE");
            }
            customerRepository.save(customer);
        }
    }
}
