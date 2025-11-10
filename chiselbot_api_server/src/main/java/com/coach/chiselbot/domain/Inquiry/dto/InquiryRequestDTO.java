package com.coach.chiselbot.domain.Inquiry.dto;


import lombok.*;

public class InquiryRequestDTO {

    @Getter
    @Setter
    @ToString
    @AllArgsConstructor
    public static class PageInfo {
        private int number;      // 1-based 표시용
        private int index;       // 0-based 실제 쿼리 파라미터용
        private boolean current; // 현재 페이지 여부
    }

    @Getter
    @Setter
    @NoArgsConstructor
    @AllArgsConstructor
    public static class Create {
        private String title;
        private String content;
    }

    @Getter
    @Setter
    @NoArgsConstructor
    @AllArgsConstructor
    public static class Update {
        private String title;
        private String content;
        // 관리자 답변용 (임시)
        private String answerContent;
    }

}
