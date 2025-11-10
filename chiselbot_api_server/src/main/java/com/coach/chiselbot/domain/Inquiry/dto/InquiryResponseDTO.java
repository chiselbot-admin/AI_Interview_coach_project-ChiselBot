package com.coach.chiselbot.domain.Inquiry.dto;

import com.coach.chiselbot.domain.Inquiry.Inquiry;
import com.coach.chiselbot.domain.Inquiry.InquiryStatus;
import com.coach.chiselbot.domain.answer.Answer;
import com.coach.chiselbot.domain.notice.Notice;
import lombok.*;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

public class InquiryResponseDTO {

    @Getter
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class UserInquiryList {
        private Long inquiryId;
        private String title;
        private InquiryStatus status;
        private String author;
        private LocalDateTime createdAt;

        public static UserInquiryList from(Inquiry inquiry) {
            return UserInquiryList.builder()
                    .inquiryId(inquiry.getId())
                    .title(inquiry.getTitle())
                    .status(inquiry.getStatus())
                    .author(inquiry.getUser().getName())
                    .createdAt(inquiry.getCreatedAt())
                    .build();
        }
    }

    @Getter
    @Setter
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class AdminInquiryList {
        private Long inquiryId;
        private String title;
        private String userName;
        private InquiryStatus status;
        private String createdAt;
        private String answerCreatedAt;
        private int displayNumber;

        public AdminInquiryList(Inquiry inquiry) {
            this.inquiryId = inquiry.getId();
            this.title = inquiry.getTitle();
            this.userName = inquiry.getUser().getName();
            this.status = inquiry.getStatus();

            DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm");
            // view에 띄우기 위해 포맷(yyyy-MM-dd HH:mm)
            this.createdAt = inquiry.getCreatedAt() != null ? inquiry.getCreatedAt().format(formatter) : null;
            this.answerCreatedAt = inquiry.getAnswer().getCreatedAt() != null ? inquiry.getAnswer().getCreatedAt().format(formatter) : null;
        }

        public static AdminInquiryList from(Inquiry inquiry) {
            DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");

            String answerCreated = (inquiry.getAnswer() != null)
                    ? formatDate(inquiry.getAnswer().getCreatedAt(), formatter)
                    : "-";

            return AdminInquiryList.builder()
                    .inquiryId(inquiry.getId())
                    .title(inquiry.getTitle())
                    .userName(inquiry.getUser().getName())
                    .status(inquiry.getStatus())
                    .createdAt(inquiry.getCreatedAt().format(formatter))
                    .answerCreatedAt(answerCreated)
                    .build();
        }

        private static String formatDate(LocalDateTime dateTime, DateTimeFormatter formatter) {
            if (dateTime == null) return "-";
            return dateTime.format(formatter);
        }

        public boolean isWaiting() {
            return status == InquiryStatus.WAITING;
        }

        public boolean isAnswered() {
            return status == InquiryStatus.ANSWERED;
        }

        public boolean isClosed() {
            return status == InquiryStatus.CLOSED;
        }
    }

    @Getter
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class UserInquiryDetail {
        private Long inquiryId;
        private String title;
        private String content;
        private InquiryStatus status;
        private String author;
        private LocalDateTime createdAt;
        // 추가
        private Long userId;
        private String answerContent;
        private LocalDateTime answeredAt;
        private LocalDateTime updatedAt;

        public static UserInquiryDetail from(Inquiry inquiry) {
            Answer a = inquiry.getAnswer();
            return UserInquiryDetail.builder()
                    .inquiryId(inquiry.getId())
                    .title(inquiry.getTitle())
                    .content(inquiry.getContent())
                    .status(inquiry.getStatus())
                    .createdAt(inquiry.getCreatedAt())
                    // 추가
                    .userId(inquiry.getUser() != null ? inquiry.getUser().getId() : null)
                    .answerContent(a != null ? a.getContent() : null)
                    .answeredAt(a != null ? a.getCreatedAt() : null)
                    .updatedAt(inquiry.getModifiedAt())
                    .author(inquiry.getUser() != null ? inquiry.getUser().getName() : null)
                    .build();
        }

    }

    @Getter
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class AdminInquiryDetail {
        private Long inquiryId;
        private Long answerId;
        private String title;
        private String content;
        private InquiryStatus status;
        private String userName;
        private String answerContent;
        private LocalDateTime createdAt;
        private LocalDateTime answeredAt;
        private LocalDateTime modifiedAt;

        public static AdminInquiryDetail from(Inquiry inquiry) {
            Answer answer = inquiry.getAnswer();
            return AdminInquiryDetail.builder()
                    .inquiryId(inquiry.getId())
                    .answerId(answer != null ? answer.getId() : null)
                    .title(inquiry.getTitle())
                    .content(inquiry.getContent())
                    .status(inquiry.getStatus())
                    .userName(inquiry.getUser().getName())
                    .answerContent(answer != null ? answer.getContent() : null)
                    .createdAt(inquiry.getCreatedAt())
                    .answeredAt(answer != null ? answer.getCreatedAt() : null)
                    .build();
        }

        public boolean isWaiting() {
            return status == InquiryStatus.WAITING;
        }

        public boolean isAnswered() {
            return status == InquiryStatus.ANSWERED;
        }

        public boolean isClosed() {
            return status == InquiryStatus.CLOSED;
        }

    }
}
