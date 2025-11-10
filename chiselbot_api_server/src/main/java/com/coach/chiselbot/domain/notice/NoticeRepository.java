package com.coach.chiselbot.domain.notice;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface NoticeRepository extends JpaRepository<Notice, Long> {

    Optional<Notice> findFirstByNoticeIdLessThanOrderByNoticeIdDesc(Long id); // 이전글
    Optional<Notice> findFirstByNoticeIdGreaterThanOrderByNoticeIdAsc(Long id); // 다음글

    List<Notice> findByIsVisibleTrueOrderByNoticeIdDesc();
}
