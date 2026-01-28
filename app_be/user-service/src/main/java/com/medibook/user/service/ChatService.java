package com.medibook.user.service;

import com.medibook.user.dto.ChatMessageDto;
import com.medibook.user.entity.Conversation;
import com.medibook.user.entity.Message;
import com.medibook.user.entity.Profile;
import com.medibook.user.repository.ConversationRepository;
import com.medibook.user.repository.DoctorRepository;
import com.medibook.user.repository.MessageRepository;
import com.medibook.user.repository.ProfileRepository;
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
        private final ProfileRepository profileRepository;
        private final DoctorRepository doctorRepository;

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
                // Check both combinations for existing conversation
                return conversationRepository.findByDoctorIdAndUserId(id1, id2)
                                .or(() -> conversationRepository.findByDoctorIdAndUserId(id2, id1))
                                .orElseGet(() -> {
                                        // Determine who is the doctor by checking DoctorRepository
                                        // Doctor entity has user_id field referring to users table
                                        boolean id1IsDoctor = doctorRepository.findByUserId(id1).isPresent();
                                        boolean id2IsDoctor = doctorRepository.findByUserId(id2).isPresent();

                                        UUID doctorId;
                                        UUID userId;

                                        if (id1IsDoctor && !id2IsDoctor) {
                                                doctorId = id1;
                                                userId = id2;
                                        } else if (id2IsDoctor && !id1IsDoctor) {
                                                doctorId = id2;
                                                userId = id1;
                                        } else {
                                                // Fallback: assume id2 (receiver) is doctor when patient initiates
                                                log.warn("Could not determine doctor role. Assuming receiver is doctor.");
                                                doctorId = id2;
                                                userId = id1;
                                        }

                                        log.info("Creating conversation: doctorId={}, userId={}", doctorId, userId);
                                        return conversationRepository.save(Conversation.builder()
                                                        .doctorId(doctorId)
                                                        .userId(userId)
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

        public java.util.List<com.medibook.user.dto.ConversationDto> getConversationsForUser(UUID userId,
                        boolean isDoctor) {
                java.util.List<Conversation> conversations;
                if (isDoctor) {
                        conversations = conversationRepository.findByDoctorId(userId);
                } else {
                        conversations = conversationRepository.findByUserId(userId);
                }

                return conversations.stream().map(conv -> {
                        // Get last message
                        var lastMsgOpt = messageRepository.findTopByConversationIdOrderByCreatedAtDesc(conv.getId());
                        String lastMessage = lastMsgOpt.map(Message::getContent).orElse("");
                        String lastMessageTime = lastMsgOpt.map(m -> m.getCreatedAt().toString()).orElse("");

                        // Count unread messages (messages not sent by current user and not read)
                        int unreadCount = messageRepository
                                        .countByConversationIdAndSenderIdNotAndIsReadFalse(conv.getId(), userId);

                        // Get profile info for the other participant
                        String patientName = "Bệnh nhân";
                        String patientAvatar = null;
                        String doctorName = "Bác sĩ";
                        String doctorAvatar = null;

                        // Fetch patient profile (userId in conversation)
                        var patientProfile = profileRepository.findByUserId(conv.getUserId());
                        if (patientProfile.isPresent()) {
                                Profile p = patientProfile.get();
                                patientName = p.getFullName() != null ? p.getFullName() : "Bệnh nhân";
                                patientAvatar = p.getAvatarUrl();
                        }

                        // Fetch doctor profile (doctorId in conversation)
                        var doctorProfile = profileRepository.findByUserId(conv.getDoctorId());
                        if (doctorProfile.isPresent()) {
                                Profile d = doctorProfile.get();
                                doctorName = d.getFullName() != null ? d.getFullName() : "Bác sĩ";
                                doctorAvatar = d.getAvatarUrl();
                        }

                        return com.medibook.user.dto.ConversationDto.builder()
                                        .id(conv.getId().toString())
                                        .doctorId(conv.getDoctorId().toString())
                                        .userId(conv.getUserId().toString())
                                        .patientName(patientName)
                                        .patientAvatar(patientAvatar)
                                        .doctorName(doctorName)
                                        .doctorAvatar(doctorAvatar)
                                        .lastMessage(lastMessage)
                                        .lastMessageTime(lastMessageTime)
                                        .unreadCount(unreadCount)
                                        .build();
                }).collect(java.util.stream.Collectors.toList());
        }
}
