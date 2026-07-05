package com.medibook.user.controller;

import com.medibook.common.dto.ApiResponse;
import com.medibook.user.dto.ChatbotRequest;
import com.medibook.user.dto.ChatbotResponse;
import com.medibook.user.service.ChatbotService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/chat")
@RequiredArgsConstructor
@Slf4j
@Tag(name = "Chatbot", description = "API Trợ lý ảo tư vấn sức khỏe")
public class ChatbotController {

    private final ChatbotService chatbotService;

    @PostMapping("/bot")
    @Operation(summary = "Gửi tin nhắn hỏi đáp sức khỏe với Chatbot AI")
    public ResponseEntity<ApiResponse<ChatbotResponse>> askChatbot(@RequestBody ChatbotRequest request) {
        log.info("API request to chatbot received");
        ChatbotResponse response = chatbotService.processMessage(request);
        return ResponseEntity.ok(ApiResponse.success("Hỏi đáp chatbot thành công", response));
    }
}
