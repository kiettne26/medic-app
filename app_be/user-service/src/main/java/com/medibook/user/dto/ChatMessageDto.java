package com.medibook.user.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.UUID;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ChatMessageDto {
    private String id;
    private String conversationId;
    private String senderId;
    private String receiverId; // To find/create conversation
    private String content;
    private String imageUrl;
    private String type; // TEXT, IMAGE
    private String createdAt;
}
