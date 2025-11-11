package com.coach.chiselbot.domain.notice.dto;

import com.coach.chiselbot.domain.admin.Admin;
import com.coach.chiselbot.domain.interview_question.InterviewQuestion;
import com.coach.chiselbot.domain.notice.Notice;
import com.coach.chiselbot.domain.notice.NoticeRepository;
import lombok.Getter;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;

public class NoticeResponse {

    @Getter
    public static class FindById{
        private final Long noticeId;
        private final String title;
        private final String content;
        private final Integer viewCount;
        private final boolean isVisible;
        private final String createdAt;
        private final String modifiedAt;
        private final String authorName;

        public FindById(Notice notice) {
            this.noticeId = notice.getNoticeId();
            this.title = notice.getTitle();
            this.content = notice.getContent();
            this.viewCount = notice.getViewCount();
            this.isVisible = notice.getIsVisible();
            //this.isVisible = notice.getIsVisible() ? "공개" : "비공개";

            DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm");
            // view에 띄우기 위해 포맷(yyyy-MM-dd HH:mm)
            this.createdAt = notice.getCreatedAt() != null ? notice.getCreatedAt().format(formatter) : null;
            this.modifiedAt = notice.getModifiedAt() != null ? notice.getModifiedAt().format(formatter) : null;
            this.authorName = notice.getAdmin().getAdminName();
        }

        private String nvl(String value) {
            return value != null ? value : "";
        }

    }

    @Getter
    public static class FindAll{
        private final Long noticeId;
        private final String title;
        private final String content;
        private final Integer viewCount;
        private final boolean isVisible;
        private final String createdAt;
        private final String modifiedAt;
        private final String authorName;

        public FindAll(Notice notice) {
            this.noticeId = notice.getNoticeId();
            this.title = notice.getTitle();
            this.content = notice.getContent();
            this.viewCount = notice.getViewCount();
            this.isVisible = notice.getIsVisible();

            DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm");
            // view에 띄우기 위해 포맷(yyyy-MM-dd HH:mm)
            this.createdAt = notice.getCreatedAt() != null ? notice.getCreatedAt().format(formatter) : null;
            this.modifiedAt = notice.getModifiedAt() != null ? notice.getModifiedAt().format(formatter) : null;
            this.authorName = notice.getAdmin().getAdminName();
        }

        public static FindAll from(Notice notice){return new FindAll(notice);}

        public static List<FindAll> from(List<Notice> notices){
            List<FindAll> dtoList = new ArrayList<>();
            for(Notice notice : notices){
                dtoList.add(new FindAll(notice));
            }
            return dtoList;
        }

        private String nvl(String value) {
            return value != null ? value : "";
        }
    }
}
