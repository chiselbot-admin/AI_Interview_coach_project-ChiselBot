package com.coach.chiselbot.domain.interview_coach;

import com.coach.chiselbot._global.common.Define;
import com.coach.chiselbot._global.errors.exception.Exception404;
import com.coach.chiselbot._global.errors.exception.Exception500;
import com.coach.chiselbot.domain.interview_coach.dto.FeedbackRequest;
import com.coach.chiselbot.domain.interview_coach.dto.FeedbackResponse;
import com.coach.chiselbot.domain.interview_coach.feedback.FeedbackStrategy;
import com.coach.chiselbot.domain.interview_coach.feedback.FeedbackStrategyFactory;
import com.coach.chiselbot.domain.interview_coach.prompt.PromptFactory;
import com.coach.chiselbot.domain.interview_question.InterviewLevel;
import com.coach.chiselbot.domain.interview_question.InterviewQuestion;
import com.coach.chiselbot.domain.interview_question.InterviewQuestionRepository;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.ai.chat.model.ChatModel;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class InterviewCoachService {

    private final FeedbackStrategyFactory feedbackStrategyFactory;
    private final PromptFactory promptFactory;
    private final ChatModel chatModel;
    private final ObjectMapper objectMapper; // json 변환용
    private final InterviewQuestionRepository questionRepository;

    public FeedbackResponse.FeedbackResult getFeedback(FeedbackRequest.AnswerRequest feedbackRequest) {

        InterviewQuestion question = questionRepository.findById(feedbackRequest.getQuestionId())
                .orElseThrow(() -> new Exception404(Define.QUESTION_NOT_FOUND));


        FeedbackStrategy feedbackStrategy =
                feedbackStrategyFactory.getStrategy(question.getInterviewLevel());

        FeedbackResponse.SimilarityResult similarity = feedbackStrategy.calculateSimilarity(feedbackRequest.getUserAnswer(), question);

        // 1. 유사도 계산 - Modify: LEVEL 1만 유사도 사용
        if(question.getInterviewLevel() == InterviewLevel.LEVEL_1){

            similarity = new FeedbackResponse.SimilarityResult(
                    Double.parseDouble(String.format("%.2f", similarity.getIntentSimilarity())),
                    similarity.getPointSimilarity());
        }

        // 2. 프롬프트 생성
        String prompt = promptFactory.createPrompt(question, feedbackRequest.getUserAnswer(), similarity);

        // 3. AI 모델 호출 - 응답 받기
        String aiAnswer = chatModel.call(prompt);

        // 4. JSON 문자열 형태 응답 -> DTO 변환
        FeedbackResponse.FeedbackResult result = null;
        try {
            result = objectMapper.readValue(aiAnswer, FeedbackResponse.FeedbackResult.class);
            result.setUserAnswer(feedbackRequest.getUserAnswer());
            result.setQuestionId(question.getQuestionId());
            if(question.getInterviewLevel() == InterviewLevel.LEVEL_1){
                result.setQuestionAnswer(question.getAnswerText());
            }
            else {
                result.setIntentText(question.getIntentText());
                result.setPointText(question.getPointText());
            }
        } catch (JsonProcessingException e) {
            throw new Exception500("AI 응답 변환 실패: " + (aiAnswer + " & ERROR : " + e));
        }

        return result;
    }

}
