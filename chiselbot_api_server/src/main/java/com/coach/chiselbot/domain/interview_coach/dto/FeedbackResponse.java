package com.coach.chiselbot.domain.interview_coach.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.Setter;
import lombok.ToString;

public class FeedbackResponse {

    @Getter
    @AllArgsConstructor
    public static class SimilarityResult{
        // 코사인 유사도 반환 DTO
        private double intentSimilarity; // LEVEL_1의 경우 answerSimilarity 용으로 사용
        private double pointSimilarity;
    }

    @Getter
    @AllArgsConstructor
    @ToString
    @Setter
    public static class FeedbackResult{
        private Long questionId;
        private double similarity; // Level1용
        private String feedback;
        private String hint;
        private String userAnswer;
        private String questionAnswer;

        // LEVEL2+ 확장
        private String intentText;   // 질문 의도
        private String pointText;    // 핵심 포인트
        private String grade; //(상/중/하)
    }

}
