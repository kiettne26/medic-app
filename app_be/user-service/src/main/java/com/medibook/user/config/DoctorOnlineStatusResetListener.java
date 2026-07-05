package com.medibook.user.config;

import com.medibook.user.repository.DoctorRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.context.event.ApplicationReadyEvent;
import org.springframework.context.event.EventListener;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

/**
 * Khi server khởi động, đặt tất cả bác sĩ về trạng thái offline.
 * Chỉ khi bác sĩ đăng nhập vào hệ thống mới chuyển sang online.
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class DoctorOnlineStatusResetListener {

    private final DoctorRepository doctorRepository;

    @EventListener(ApplicationReadyEvent.class)
    @Transactional
    public void resetAllDoctorsToOffline() {
        doctorRepository.setAllDoctorsOffline();
        log.info("All doctors have been set to offline on server startup");
    }
}
