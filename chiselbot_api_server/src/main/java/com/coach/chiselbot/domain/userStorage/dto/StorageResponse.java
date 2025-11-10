package com.coach.chiselbot.domain.userStorage.dto;


import com.coach.chiselbot.domain.userStorage.UserStorage;
import lombok.Getter;
import lombok.Setter;

import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;

public class StorageResponse {

    @Getter
    public static class FindById {
        private final Long storageId;
        private final Long questionId;
        private final Long userId;
        private final String questionText;
        private final String userAnswer;
        private final String feedback;
        private final String hint;
        private final Double similarity;
        private final String interviewLevel;
        private final String categoryName;
        private final String createdAt;
        private final String questionAnswer;
        private final String grade;
        private final String intentText;
        private final String pointText;

        public FindById(UserStorage storage) {
            this.storageId = storage.getStorageId();
            this.questionId = storage.getQuestion().getQuestionId();
            this.userId = storage.getUser().getId();
            this.questionText = storage.getQuestion().getQuestionText();
            this.questionAnswer = storage.getQuestion().getAnswerText();
            this.userAnswer = nvl(storage.getUserAnswer());
            this.feedback = nvl(storage.getFeedback());
            this.hint = nvl(storage.getHint());
            this.similarity = storage.getSimilarity();
            this.interviewLevel = storage.getQuestion().getInterviewLevel().name();
            this.categoryName = storage.getQuestion().getCategoryId().getName();
            DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm");
            this.createdAt = storage.getCreatedAt() != null ? storage.getCreatedAt().format(formatter) : null;
            this.grade = storage.getGrade();
            this.pointText = storage.getQuestion().getPointText();
            this.intentText = storage.getQuestion().getIntentText();
        }

        private String nvl(String value) {
            return value != null ? value : "";
        }
    }

    @Getter
    @Setter
    public static class FindAll{
        private final Long storageId;
        private final Long questionId;
        private final Long userId;
        private final String questionText;
        private final String userAnswer;
        private final String feedback;
        private final String hint;
        private final Double similarity;
        private final String interviewLevel;
        private final String categoryName;
        private final String createdAt;
        private final String grade;
        private final String intentText;
        private final String pointText;

        public FindAll(UserStorage storage) {
            this.storageId = storage.getStorageId();
            this.questionId = storage.getQuestion().getQuestionId();
            this.userId = storage.getUser().getId();
            this.questionText = storage.getQuestion().getQuestionText();
            this.userAnswer = nvl(storage.getUserAnswer());
            this.feedback = nvl(storage.getFeedback());
            this.hint = nvl(storage.getHint());
            this.similarity = storage.getSimilarity();
            this.interviewLevel = storage.getQuestion().getInterviewLevel().name();
            this.categoryName = storage.getQuestion().getCategoryId().getName();
            DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm");
            this.createdAt = storage.getCreatedAt() != null ? storage.getCreatedAt().format(formatter) : null;
            this.grade = storage.getGrade();
            this.pointText = storage.getQuestion().getPointText();
            this.intentText = storage.getQuestion().getIntentText();
        }

        public static List<StorageResponse.FindAll> from(List<UserStorage> questions){
            List<StorageResponse.FindAll> dtoList = new ArrayList<>();
            for(UserStorage question : questions){
                dtoList.add(new StorageResponse.FindAll(question));
            }
            return dtoList;
        }

        private String nvl(String value) {
            return value != null ? value : "";
        }
    }
}
