package com.medibook.user.controller;

import com.medibook.user.dto.ChatMessageDto;
import com.medibook.user.service.ChatService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.http.ResponseEntity;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.Payload;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import java.util.UUID;

@Controller
@RequiredArgsConstructor
@Slf4j
public class ChatController {

    private final SimpMessagingTemplate messagingTemplate;
    private final ChatService chatService;

    // WebSocket Endpoint
    @MessageMapping("/chat")
    public void processMessage(@Payload ChatMessageDto chatMessage) {
        log.info("Received message: {}", chatMessage);

        // Save to DB
        ChatMessageDto saved = chatService.saveMessage(chatMessage);

        // Publish to topic: /topic/conversation/{conversationId} for ChatScreen
        messagingTemplate.convertAndSend("/topic/conversation/" + saved.getConversationId(), saved);

        // Publish to receiver's notification topic for MessagesScreen real-time update
        if (chatMessage.getReceiverId() != null) {
            messagingTemplate.convertAndSend("/topic/user/" + chatMessage.getReceiverId() + "/notification", saved);
        }
    }

    // HTTP Endpoint for history
    @GetMapping("/api/chat/history/{conversationId}")
    @ResponseBody
    public ResponseEntity<Page<ChatMessageDto>> getChatHistory(
            @PathVariable String conversationId,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        return ResponseEntity.ok(chatService.getMessages(UUID.fromString(conversationId), PageRequest.of(page, size)));
    }

    // Get or create conversation and return with messages
    @GetMapping("/api/chat/conversation")
    @ResponseBody
    public ResponseEntity<?> getOrCreateConversation(
            @RequestParam String userId,
            @RequestParam String doctorId,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        try {
            UUID userUuid = UUID.fromString(userId);
            UUID doctorUuid = UUID.fromString(doctorId);

            var result = chatService.getOrCreateConversationWithMessages(userUuid, doctorUuid,
                    PageRequest.of(page, size));
            return ResponseEntity.ok(result);
        } catch (Exception e) {
            log.error("Error getting conversation: {}", e.getMessage());
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }

    // Get list of conversations for a user
    @GetMapping("/api/chat/conversations")
    @ResponseBody
    public ResponseEntity<?> getConversations(
            @RequestParam String userId,
            @RequestParam(defaultValue = "false") boolean isDoctor) {
        try {
            UUID userUuid = UUID.fromString(userId);
            var result = chatService.getConversationsForUser(userUuid, isDoctor);
            return ResponseEntity.ok(result);
        } catch (Exception e) {
            log.error("Error getting conversations: {}", e.getMessage());
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }
}
