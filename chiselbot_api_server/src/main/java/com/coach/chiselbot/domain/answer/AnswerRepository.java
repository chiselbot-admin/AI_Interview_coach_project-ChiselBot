package com.coach.chiselbot.domain.answer;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Optional;

public interface AnswerRepository extends JpaRepository<Answer, Long> {

    @Query("SELECT a FROM Answer a JOIN FETCH a.inquiry WHERE a.id = :id")
    Optional<Answer> findByIdWithInquiry(@Param("id") Long id);
}
