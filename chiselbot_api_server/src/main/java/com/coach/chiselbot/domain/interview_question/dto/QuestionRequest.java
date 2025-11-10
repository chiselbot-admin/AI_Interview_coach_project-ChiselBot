package com.coach.chiselbot.domain.interview_question.dto;

import com.coach.chiselbot.domain.interview_question.InterviewLevel;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.Setter;
import lombok.ToString;

public class QuestionRequest {

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
    public static class CreateQuestion {
        private Long categoryId;
        private Long adminId;
        private InterviewLevel interviewLevel;
        private String questionText;
        private String intentText;
        private String pointText;
        private String intentVector;
        private String pointVector;
        private String answerText;
        private String answerVector;
    }

    @Getter
    @Setter
    public static class UpdateQuestion{
        private Long questionId;
        private Long categoryId;
        private Long adminId;
        private InterviewLevel interviewLevel;
        private String questionText;
        private String intentText;
        private String pointText;
        private String answerText;
    }
}
