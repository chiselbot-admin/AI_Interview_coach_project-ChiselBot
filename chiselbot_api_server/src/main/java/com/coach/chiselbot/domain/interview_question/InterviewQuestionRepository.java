package com.coach.chiselbot.domain.interview_question;

import com.coach.chiselbot.domain.dashboard.CategoryQuestionCount;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;
import java.util.Optional;

public interface InterviewQuestionRepository extends JpaRepository<InterviewQuestion, Long> {

    Optional<InterviewQuestion> findFirstByCategoryId_CategoryIdAndInterviewLevel(Long categoryId, InterviewLevel  interviewLevel);

    @Query("""
    SELECT q.categoryId.name AS categoryName,
           COUNT(q) AS questionCount
    FROM InterviewQuestion q
    GROUP BY q.categoryId.name""")
    List<CategoryQuestionCount> countQuestionsByCategory();

    long countByCategoryId_CategoryIdAndInterviewLevel(Long categoryId, InterviewLevel level);

    Page<InterviewQuestion> findByCategoryId_CategoryIdAndInterviewLevel(
            Long categoryId, InterviewLevel level, Pageable pageable);
}
