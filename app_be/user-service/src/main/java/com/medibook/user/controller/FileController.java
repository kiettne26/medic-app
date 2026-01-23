package com.medibook.user.controller;

import com.medibook.common.dto.ApiResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/users")
@RequiredArgsConstructor
public class FileController {

    @Value("${supabase.url}")
    private String supabaseUrl;

    @Value("${supabase.key}")
    private String supabaseKey;

    @Value("${supabase.bucket}")
    private String bucketName;

    @PostMapping("/upload")
    public ResponseEntity<ApiResponse<Map<String, String>>> uploadFile(@RequestParam("file") MultipartFile file) {
        try {
            if (file.isEmpty()) {
                return ResponseEntity.badRequest().body(ApiResponse.error("File is empty"));
            }

            String originalFileName = file.getOriginalFilename();
            if (originalFileName == null)
                originalFileName = "unknown.jpg";

            // Clean filename
            String fileName = UUID.randomUUID().toString() + "_" + originalFileName.replaceAll("[^a-zA-Z0-9._-]", "_");

            // Supabase Upload URL
            String uploadEndpoint = supabaseUrl + "/storage/v1/object/" + bucketName + "/" + fileName;

            // Prepare Headers
            HttpHeaders headers = new HttpHeaders();
            headers.set("Authorization", "Bearer " + supabaseKey);
            // Use correct content type
            String contentType = file.getContentType() != null ? file.getContentType() : "application/octet-stream";
            headers.setContentType(MediaType.valueOf(contentType));

            // Prepare Request
            HttpEntity<byte[]> requestEntity = new HttpEntity<>(file.getBytes(), headers);

            // Execute Upload
            RestTemplate restTemplate = new RestTemplate();
            restTemplate.postForEntity(uploadEndpoint, requestEntity, String.class);

            // Construct Public URL
            // Note: Public URL format depends on Bucket config but usually:
            // {url}/storage/v1/object/public/{bucket}/{fileName}
            String publicUrl = supabaseUrl + "/storage/v1/object/public/" + bucketName + "/" + fileName;

            return ResponseEntity.ok(ApiResponse.success(Map.of("url", publicUrl)));

        } catch (IOException e) {
            return ResponseEntity.internalServerError()
                    .body(ApiResponse.error("Failed to read file: " + e.getMessage()));
        } catch (Exception e) {
            // Enhanced error logging
            return ResponseEntity.internalServerError()
                    .body(ApiResponse.error("Supabase upload failed: " + e.getMessage()));
        }
    }
}
