package com.coach.chiselbot.domain.interview_coach.feedback;

import com.coach.chiselbot.domain.interview_coach.dto.FeedbackResponse;
import com.coach.chiselbot.domain.interview_question.InterviewQuestion;
import lombok.RequiredArgsConstructor;
import org.springframework.ai.openai.OpenAiEmbeddingModel;

@RequiredArgsConstructor
public abstract class AbstractFeedbackStrategy implements FeedbackStrategy {

    //private final OpenAiChatModel chatModel;

    protected final OpenAiEmbeddingModel embeddingModel;

    // 텍스트 임베딩
    protected float[] embed(String text) {
        return embeddingModel.embed(text);
    }

    // 코사인 유사도 계산 함수
    protected double cosineSimilarity(float[] a, float[] b) {
        double dot = 0, normA = 0, normB = 0;
        for (int i = 0; i < a.length; i++) {
            dot += a[i] * b[i];
            normA += a[i] * a[i];
            normB += b[i] * b[i];
        }
        return dot / (Math.sqrt(normA) * Math.sqrt(normB));
    }

    // 추상메서드로 그대로 하위클래스에 넘겨줌
    public abstract FeedbackResponse.SimilarityResult calculateSimilarity(String userAnswer, InterviewQuestion question);

}
