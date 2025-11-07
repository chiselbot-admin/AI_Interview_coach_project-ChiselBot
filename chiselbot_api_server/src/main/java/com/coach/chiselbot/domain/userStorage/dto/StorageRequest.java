package com.coach.chiselbot.domain.userStorage.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

public class StorageRequest {

    @Getter
    @Setter
    @AllArgsConstructor
    @NoArgsConstructor
    public static class SaveRequest{
        private Long userId;
        private Long questionId;
        private String userAnswer;
        private String feedback;
        private String hint;
        private Double similarity;
        private String grade;
    }
}
