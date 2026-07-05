package com.medibook.user.repository;

import com.medibook.user.entity.Message;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.UUID;

@Repository
public interface MessageRepository extends JpaRepository<Message, UUID> {
    Page<Message> findByConversationIdOrderByCreatedAtDesc(UUID conversationId, Pageable pageable);

    Optional<Message> findTopByConversationIdOrderByCreatedAtDesc(UUID conversationId);

    int countByConversationIdAndSenderIdNotAndIsReadFalse(UUID conversationId, UUID currentUserId);

    @org.springframework.data.jpa.repository.Modifying
    @org.springframework.data.jpa.repository.Query("UPDATE Message m SET m.isRead = true WHERE m.conversation.id = :conversationId AND m.senderId <> :readerId AND m.isRead = false")
    void markAsRead(
        @org.springframework.data.repository.query.Param("conversationId") UUID conversationId, 
        @org.springframework.data.repository.query.Param("readerId") UUID readerId
    );
}
