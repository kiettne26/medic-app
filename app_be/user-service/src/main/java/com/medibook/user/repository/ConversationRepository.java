package com.medibook.user.repository;

import com.medibook.user.entity.Conversation;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.UUID;
import java.util.List;

@Repository
public interface ConversationRepository extends JpaRepository<Conversation, UUID> {
    Optional<Conversation> findByDoctorIdAndUserId(UUID doctorId, UUID userId);

    List<Conversation> findByUserId(UUID userId);

    List<Conversation> findByDoctorId(UUID doctorId);
}
