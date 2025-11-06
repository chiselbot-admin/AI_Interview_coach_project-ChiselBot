package com.coach.chiselbot.domain.interview_coach.feedback;

import com.coach.chiselbot.domain.interview_coach.dto.FeedbackResponse;
import com.coach.chiselbot.domain.interview_question.InterviewQuestion;
import org.springframework.ai.openai.OpenAiEmbeddingModel;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

@Component
public class Level2FeedbackStrategy extends AbstractFeedbackStrategy {

    @Autowired
    public Level2FeedbackStrategy(OpenAiEmbeddingModel embeddingModel) {
        super(embeddingModel);
    }

    @Override
    public FeedbackResponse.SimilarityResult calculateSimilarity(String userAnswer, InterviewQuestion question) {
//        Gson gson = new Gson();
//
//        float[] userVec = embed(userAnswer);
//
//        float[] intentVec = gson.fromJson(question.getIntentVector(), float[].class);
//        float[] pointVec = gson.fromJson(question.getPointVector(), float[].class);
//
//        double intentSim = cosineSimilarity(userVec, intentVec);
//        double pointSim = cosineSimilarity(userVec, pointVec);

        return new FeedbackResponse.SimilarityResult(0.0, 0.0);
    }
}
