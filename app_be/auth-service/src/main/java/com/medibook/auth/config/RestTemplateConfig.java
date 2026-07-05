package com.medibook.auth.config;

import org.springframework.cloud.client.loadbalancer.LoadBalanced;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.client.RestTemplate;

/**
 * Cấu hình RestTemplate với Load Balancing cho Service Discovery
 * Sử dụng Eureka để resolve service name thành URL
 */
@Configuration
public class RestTemplateConfig {

    /**
     * RestTemplate với @LoadBalanced để sử dụng service name từ Eureka
     * Ví dụ: http://user-service/doctors thay vì http://localhost:8082/doctors
     */
    @Bean
    @LoadBalanced
    public RestTemplate restTemplate() {
        return new RestTemplate();
    }
}
