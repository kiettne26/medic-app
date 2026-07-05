package com.medibook.user.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.medibook.user.dto.ChatbotRequest;
import com.medibook.user.dto.ChatbotResponse;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Slf4j
@Service
public class ChatbotService {

    @Value("${gemini.api.key:}")
    private String apiKey;

    private final RestTemplate restTemplate = new RestTemplate();
    private final ObjectMapper objectMapper = new ObjectMapper();

    public ChatbotResponse processMessage(ChatbotRequest request) {
        String msg = request.getMessage() != null ? request.getMessage().trim() : "";
        log.info("Processing chatbot message. Gemini API key configured: {}", 
                 (apiKey != null && !apiKey.trim().isEmpty()));

        if (apiKey != null && !apiKey.trim().isEmpty()) {
            try {
                String url = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=" + apiKey;

                // Chuẩn bị Headers
                HttpHeaders headers = new HttpHeaders();
                headers.setContentType(MediaType.APPLICATION_JSON);

                // Tạo prompt yêu cầu cấu trúc JSON đầu ra
                String systemPrompt = "Bạn là Trợ lý sức khỏe ảo của hệ thống khám bệnh MediBook. "
                        + "Hãy tư vấn triệu chứng y tế và khuyên họ đi khám một cách ân cần, lịch sự bằng tiếng Việt. "
                        + "Trả về duy nhất định dạng JSON nguyên bản (RAW JSON), không dùng định dạng markdown bao ngoài. "
                        + "Cấu trúc JSON bắt buộc phải như sau: "
                        + "{\"reply\": \"[câu trả lời tư vấn chi tiết của bạn]\", \"suggestedSpecialty\": \"[tên chuyên khoa gợi ý]\"}. "
                        + "Tên chuyên khoa trong 'suggestedSpecialty' bắt buộc phải chọn chính xác 1 trong 5 loại sau: "
                        + "[Tim mạch, Nhi khoa, Da liễu, Răng Hàm Mặt, Nội tổng quát] dựa trên triệu chứng của người dùng.";

                String fullPrompt = systemPrompt + "\n\nCâu hỏi của người dùng: " + msg;

                // Chuẩn bị Body theo định dạng API Google Gemini
                Map<String, Object> textPart = new HashMap<>();
                textPart.put("text", fullPrompt);

                Map<String, Object> partContainer = new HashMap<>();
                partContainer.put("parts", List.of(textPart));

                Map<String, Object> body = new HashMap<>();
                body.put("contents", List.of(partContainer));

                // Bắt buộc đầu ra JSON ở cấu hình sinh
                Map<String, Object> generationConfig = new HashMap<>();
                generationConfig.put("responseMimeType", "application/json");
                body.put("generationConfig", generationConfig);

                HttpEntity<Map<String, Object>> entity = new HttpEntity<>(body, headers);

                log.info("Sending request to Gemini API...");
                ResponseEntity<String> response = restTemplate.postForEntity(url, entity, String.class);

                if (response.getStatusCode().is2xxSuccessful() && response.getBody() != null) {
                    JsonNode rootNode = objectMapper.readTree(response.getBody());
                    String jsonText = rootNode.path("candidates")
                            .get(0)
                            .path("content")
                            .path("parts")
                            .get(0)
                            .path("text")
                            .asText();

                    // Làm sạch chuỗi JSON nếu có bao bọc bởi markdown block
                    jsonText = jsonText.trim();
                    if (jsonText.startsWith("```")) {
                        jsonText = jsonText.replaceAll("```json|```", "").trim();
                    }

                    log.info("Gemini raw text output: {}", jsonText);

                    JsonNode aiResponseNode = objectMapper.readTree(jsonText);
                    String reply = aiResponseNode.path("reply").asText();
                    String suggestedSpecialty = aiResponseNode.path("suggestedSpecialty").asText();

                    // Chuẩn hóa tên chuyên khoa nếu có khoảng trắng hoặc viết thường
                    suggestedSpecialty = normalizeSpecialty(suggestedSpecialty);

                    return ChatbotResponse.builder()
                            .reply(reply)
                            .suggestedSpecialty(suggestedSpecialty)
                            .build();
                }
            } catch (Exception e) {
                log.error("Error during Gemini API call, falling back to local processor. Error: {}", e.getMessage());
            }
        }

        // BỘ XỬ LÝ DỰ PHÒNG OFFLINE (FALLBACK) - Khi không có API Key hoặc gọi API lỗi
        return processLocalFallback(msg.toLowerCase());
    }

    private String normalizeSpecialty(String specialty) {
        if (specialty == null) return "Nội tổng quát";
        specialty = specialty.trim();
        if (specialty.equalsIgnoreCase("Tim mạch")) return "Tim mạch";
        if (specialty.equalsIgnoreCase("Nhi khoa")) return "Nhi khoa";
        if (specialty.equalsIgnoreCase("Da liễu")) return "Da liễu";
        if (specialty.equalsIgnoreCase("Răng Hàm Mặt")) return "Răng Hàm Mặt";
        return "Nội tổng quát";
    }

    private ChatbotResponse processLocalFallback(String msg) {
        String reply;
        String specialty = "Nội tổng quát";

        if (msg.contains("chào") || msg.contains("hello") || msg.contains("hi") || msg.contains("bạn là ai") || msg.contains("chatbot")) {
            reply = "Xin chào! Tôi là Trợ lý Sức khỏe ảo của MediBook. Tôi có thể tư vấn sơ bộ về các triệu chứng sức khỏe và gợi ý chuyên khoa khám phù hợp nhất cho bạn. Bạn đang gặp vấn đề gì thế?";
            return ChatbotResponse.builder().reply(reply).suggestedSpecialty(specialty).build();
        }

        if (msg.contains("tim") || msg.contains("ngực") || msg.contains("huyết áp") || msg.contains("đập nhanh") || msg.contains("khó thở")) {
            reply = "Dựa trên các dấu hiệu bạn mô tả (như tức ngực, khó thở, nhịp tim hay huyết áp thay đổi), đây có thể là dấu hiệu liên quan đến hệ tuần hoàn. Bạn nên ngồi nghỉ ngơi ở nơi thoáng mát, tránh vận động mạnh. Hãy đặt lịch khám với chuyên khoa **Tim mạch** để được đo điện tâm đồ (ECG) và siêu âm tim chuyên sâu.";
            specialty = "Tim mạch";
        }
        else if (msg.contains("bé") || msg.contains("trẻ") || msg.contains("con ") || msg.contains("nhi khoa") || msg.contains("sơ sinh") || msg.contains("biếng ăn")) {
            reply = "Đối với trẻ nhỏ, các triệu chứng như sốt, ho, quấy khóc hay biếng ăn cần được theo dõi hết sức cẩn thận. Bạn nên cho bé uống nhiều nước ấm, chia nhỏ bữa ăn và lau người bằng nước ấm nếu trẻ sốt dưới 38.5 độ. Hãy đặt lịch khám sớm với bác sĩ chuyên khoa **Nhi khoa** để chăm sóc bé tốt nhất.";
            specialty = "Nhi khoa";
        }
        else if (msg.contains("da") || msg.contains("ngứa") || msg.contains("mụn") || msg.contains("chàm") || msg.contains("dị ứng") || msg.contains("phát ban") || msg.contains("mẩn")) {
            reply = "Các biểu hiện nổi mẩn ngứa, mụn hay dị ứng ngoài da có thể là dấu hiệu của bệnh viêm da, chàm hoặc phản ứng dị ứng thời tiết/thức ăn. Bạn nên giữ vùng da sạch sẽ, tránh gãi gây trầy xước nhiễm trùng và không tự ý bôi các loại thuốc chứa corticoid. Khuyên bạn nên khám chuyên khoa **Da liễu** để được chẩn đoán chính xác.";
            specialty = "Da liễu";
        }
        else if (msg.contains("răng") || msg.contains("nướu") || msg.contains("lợi") || msg.contains("sâu răng") || msg.contains("chân răng")) {
            reply = "Đau nhức răng hay viêm lợi nướu có thể do sâu răng, viêm quanh chân răng hoặc mọc răng khôn. Bạn nên súc miệng bằng nước muối sinh lý ấm sau khi ăn và tránh dùng thức ăn quá nóng/lạnh hoặc quá cứng. Hãy đặt lịch khám chuyên khoa **Răng Hàm Mặt** để bác sĩ kiểm tra và điều trị kịp thời.";
            specialty = "Răng Hàm Mặt";
        }
        else {
            reply = "Chào bạn, tôi đã ghi nhận triệu chứng của bạn. Đối với các biểu hiện mệt mỏi, đau đầu nhẹ, đau bụng hoặc các khó chịu chung khác, bạn nên dành thời gian nghỉ ngơi, uống nhiều nước ấm và theo dõi thêm. Nếu triệu chứng kéo dài hoặc nặng hơn, bạn nên đặt lịch khám chuyên khoa **Nội tổng quát** để được kiểm tra sức khỏe toàn diện.";
            specialty = "Nội tổng quát";
        }

        return ChatbotResponse.builder()
                .reply(reply)
                .suggestedSpecialty(specialty)
                .build();
    }
}
