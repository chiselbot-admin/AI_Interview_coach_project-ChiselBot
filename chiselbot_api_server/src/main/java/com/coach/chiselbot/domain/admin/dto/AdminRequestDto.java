package com.coach.chiselbot.domain.admin.dto;

import lombok.*;

public class AdminRequestDto {

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public static class Login {
        private String email;
        private String password;
    }


    @Getter
    @Setter
    public static class adminCreate{
        private String adminName;
        private String email;
        private String password;
    }
}