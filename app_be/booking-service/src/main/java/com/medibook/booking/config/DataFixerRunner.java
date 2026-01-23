package com.medibook.booking.config;

import org.springframework.boot.CommandLineRunner;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Component;
import org.springframework.beans.factory.annotation.Autowired;

@Component
public class DataFixerRunner implements CommandLineRunner {

    @Autowired
    private JdbcTemplate jdbcTemplate;

    @Override
    public void run(String... args) throws Exception {
        System.out.println("--- DATA FIXER: Checking for NULL versions in time_slots ---");
        try {
            int rows = jdbcTemplate.update("UPDATE time_slots SET version = 0 WHERE version IS NULL");
            System.out.println("--- DATA FIXER: Updated " + rows + " rows with NULL version ---");
        } catch (Exception e) {
            System.out.println(
                    "--- DATA FIXER: Error updating versions (Table might not exist yet): " + e.getMessage() + " ---");
        }
    }
}
