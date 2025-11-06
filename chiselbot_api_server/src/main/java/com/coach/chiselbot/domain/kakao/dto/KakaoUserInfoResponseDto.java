package com.coach.chiselbot.domain.kakao.dto;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.util.Date;
import java.util.HashMap;

/**
 * 카카오 사용자 정보 API (/v2/user/me) 응답을 매핑하는 DTO
 * https://developers.kakao.com/docs/latest/ko/kakaologin/rest-api#req-user-info
 */
@Getter
@NoArgsConstructor
@JsonIgnoreProperties(ignoreUnknown = true)
public class KakaoUserInfoResponseDto {

    // 회원번호
    @JsonProperty("id")
    private Long id;

    // 서비스에 연결 완료된 시각
    @JsonProperty("connected_at")
    private Date connectedAt;

    // 카카오 계정 정보
    @JsonProperty("kakao_account")
    private KakaoAccount kakaoAccount;

    // 사용자 프로퍼티 (커스텀 프로필 등)
    @JsonProperty("properties")
    private HashMap<String, String> properties;

    @Getter
    @NoArgsConstructor
    @JsonIgnoreProperties(ignoreUnknown = true)
    public static class KakaoAccount {

        // 프로필
        @JsonProperty("profile")
        private Profile profile;

        // 이메일 제공 동의 여부
        @JsonProperty("email_needs_agreement")
        private Boolean isEmailAgree;

        // 이메일
        @JsonProperty("email")
        private String email;

        // 성별
        @JsonProperty("gender")
        private String gender;

        // 연령대
        @JsonProperty("age_range")
        private String ageRange;

        // 전화번호
        @JsonProperty("phone_number")
        private String phoneNumber;

        @Getter
        @NoArgsConstructor
        @JsonIgnoreProperties(ignoreUnknown = true)
        public static class Profile {
            @JsonProperty("nickname")
            private String nickName;

            @JsonProperty("profile_image_url")
            private String profileImageUrl;

            @JsonProperty("thumbnail_image_url")
            private String thumbnailImageUrl;
        }
    }
}
