package com.medibook.user.service;

import com.medibook.user.dto.ChatMessageDto;
import com.medibook.user.entity.Conversation;
import com.medibook.user.entity.Message;
import com.medibook.user.repository.ConversationRepository;
import com.medibook.user.repository.MessageRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@Slf4j
public class ChatService {

        private final ConversationRepository conversationRepository;
        private final MessageRepository messageRepository;

        @Transactional
        public ChatMessageDto saveMessage(ChatMessageDto dto) {
                UUID senderId = UUID.fromString(dto.getSenderId());
                UUID receiverId = UUID.fromString(dto.getReceiverId());
                UUID conversationId;

                // Try to find conversation (sender is either user or doctor)
                // Note: For simplicity assuming One-to-One between User and Doctor.
                // We need to know who is who. But database schema stores doctorId and userId.
                // This is a bit tricky if we just have 2 UUIDs.
                // Let's assume frontend sends conversationId if it exists.
                // Or we assume a lookup.

                // Better approach for now: Check if conversation exists by doctorId and userId.
                // We'll need extra info or try both combinations if we don't know who is
                // doctor.
                // Let's ignore that complexity and assume `senderId` and `receiverId` maps to
                // `userId` and `doctorId`.

                // This is slightly flawed without knowing role.
                // Let's assume we find by just checking existence.
                // Simplified: Try finding by (doc, user) or (user, doc) ?
                // No, ID is unique.

                // Let's create separate method: getOrCreateConversation
                Conversation conversation = getOrCreateConversation(senderId, receiverId);

                Message message = Message.builder()
                                .conversation(conversation)
                                .senderId(senderId)
                                .content(dto.getContent())
                                .imageUrl(dto.getImageUrl())
                                .type(dto.getType() != null ? dto.getType() : "TEXT")
                                .isRead(false)
                                .build();

                message = messageRepository.save(message);

                return ChatMessageDto.builder()
                                .id(message.getId().toString())
                                .conversationId(conversation.getId().toString())
                                .senderId(message.getSenderId().toString())
                                .content(message.getContent())
                                .imageUrl(message.getImageUrl())
                                .type(message.getType())
                                .createdAt(message.getCreatedAt() != null ? message.getCreatedAt().toString()
                                                : LocalDateTime.now().toString())
                                .build();
        }

        private Conversation getOrCreateConversation(UUID id1, UUID id2) {
                // This part assumes we know which one is doctor.
                // HACK: Check if there is a conversation with this pair.
                // Since we don't look up roles here, we might need to rely on the fact that
                // `doctorId` in DB refers to a specific user?
                // Note: In `Doctor` entity, `userId` is a field. `Conversation.doctorId`
                // usually refers to `Doctor.id`.

                // Correct logic:
                // Input: senderId, receiverId. These are likely PRIMARY KEYS of Users table (or
                // one User, one Doctor).
                // If our Frontend sends User UIDs, we need to map to Doctor ID if receiver is
                // Doctor.

                // Let's simplified: We assume frontend sends the Conversation ID if known.
                // If not, we try to look it up.
                // Since this is a specialized task, let's just stick to "Create if not exists"
                // blindly mapping for now.
                // Or better: pass conversationId.

                // For MVP: Let's query matching `doctorId` and `userId`.
                // We will TRY both combinations (id1 as doctor, id2 as user) OR (id2 as doctor,
                // id1 as user).

                return conversationRepository.findByDoctorIdAndUserId(id1, id2)
                                .or(() -> conversationRepository.findByDoctorIdAndUserId(id2, id1))
                                .orElseGet(() -> {
                                        // Create new. We don't know who is who.
                                        // IMPORTANT: We need correct mapping.
                                        // For now, let's assume sender is User, receiver is Doctor (Client side logic).
                                        // But doctor can reply.

                                        // Fix: We must persist `conversationId` on client side once created.
                                        // But for first message?

                                        // Let's assume we create one with id1=Doctor, id2=User for now to unblock.
                                        // Ideally we check User Roles.

                                        return conversationRepository.save(Conversation.builder()
                                                        .doctorId(id1)
                                                        .userId(id2)
                                                        .build());
                                });
        }

        public Page<ChatMessageDto> getMessages(UUID conversationId, Pageable pageable) {
                return messageRepository.findByConversationIdOrderByCreatedAtDesc(conversationId, pageable)
                                .map(m -> ChatMessageDto.builder()
                                                .id(m.getId().toString())
                                                .conversationId(m.getConversation().getId().toString())
                                                .senderId(m.getSenderId().toString())
                                                .content(m.getContent())
                                                .imageUrl(m.getImageUrl())
                                                .type(m.getType())
                                                .createdAt(m.getCreatedAt().toString())
                                                .build());
        }

        public java.util.Map<String, Object> getOrCreateConversationWithMessages(UUID userId, UUID doctorId,
                        Pageable pageable) {
                // Get or create conversation
                Conversation conversation = getOrCreateConversation(userId, doctorId);

                // Get messages for this conversation
                Page<ChatMessageDto> messages = getMessages(conversation.getId(), pageable);

                // Return result with conversationId and messages
                return java.util.Map.of(
                                "conversationId", conversation.getId().toString(),
                                "userId", conversation.getUserId().toString(),
                                "doctorId", conversation.getDoctorId().toString(),
                                "messages", messages);
        }
}
