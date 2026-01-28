package com.medibook.user.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ConversationDto {
    private String id;
    private String doctorId;
    private String userId;
    private String doctorName;
    private String patientName;
    private String patientAvatar;
    private String doctorAvatar;
    private String lastMessage;
    private String lastMessageTime;
    private int unreadCount;
}
