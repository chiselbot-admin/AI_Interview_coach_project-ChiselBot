package com.coach.chiselbot.domain.interview_coach.prompt;

import com.coach.chiselbot.domain.interview_coach.dto.FeedbackResponse;
import com.coach.chiselbot.domain.interview_question.InterviewLevel;
import com.coach.chiselbot.domain.interview_question.InterviewQuestion;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class Level2PromptStrategy implements PromptStrategy{
    private final PromptRepository promptRepository;

    @Override
    public String buildPrompt(InterviewQuestion question,
                              String userAnswer,
                              FeedbackResponse.SimilarityResult similarity) {

        Prompt prompt = promptRepository
                .findFirstByLevelAndIsActiveTrue(InterviewLevel.LEVEL_2)
                .orElseThrow(() -> new IllegalStateException("Level2 활성화 프롬프트 없음"));

        return prompt.getPromptBody().formatted(
                question.getQuestionText(),
                question.getIntentText(),
                question.getPointText(),
                userAnswer

        );
    }

    @Override
    public InterviewLevel getLevel() {
        return InterviewLevel.LEVEL_2;
    }

}
