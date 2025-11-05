package com.coach.chiselbot.domain.interview_coach.prompt.dto;

import com.coach.chiselbot.domain.interview_question.InterviewLevel;
import lombok.Getter;
import lombok.Setter;

public class PromptRequest {

    @Getter
    @Setter
    public static class CreatePrompt{
        private InterviewLevel level;
        private Boolean isActive;
        private String promptBody;
    }
}
