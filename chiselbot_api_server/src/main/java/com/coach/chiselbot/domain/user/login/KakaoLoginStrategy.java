package com.coach.chiselbot.domain.user.login;

import com.coach.chiselbot.domain.kakao.KakaoOAuthClient;
import com.coach.chiselbot.domain.kakao.RedirectRequiredException;
import com.coach.chiselbot.domain.kakao.dto.KakaoUserInfoResponseDto;
import com.coach.chiselbot.domain.user.Provider;
import com.coach.chiselbot.domain.user.User;
import com.coach.chiselbot.domain.user.UserJpaRepository;
import com.coach.chiselbot.domain.user.dto.UserRequestDTO;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;
import org.springframework.web.util.UriComponentsBuilder;

import java.util.UUID;

@Component
@RequiredArgsConstructor
public class KakaoLoginStrategy implements LoginStrategy {

    @Value("${oauth.kakao.client-id}")
    private String clientId;

    @Value("${oauth.kakao.redirect-uri}")
    private String redirectUri;


    private final KakaoOAuthClient kakaoOAuthClient;
    private final UserJpaRepository userJpaRepository;
    private final PasswordEncoder passwordEncoder;

	@Override
	public User login(UserRequestDTO.Login dto) {
		String accessToken;

		// 1. accessToken이 직접 넘어온 경우 (Flutter SDK 방식)
		if (dto.getAccessToken() != null && !dto.getAccessToken().isBlank()) {
			accessToken = dto.getAccessToken();
		}
		// 2. authCode가 넘어온 경우 (기존 웹 방식)
		else if (dto.getAuthCode() != null && !dto.getAuthCode().isBlank()) {
			accessToken = kakaoOAuthClient.getAccessToken(dto.getAuthCode());
		}
		// 3. 둘 다 없으면 리다이렉트
		else {
			String kakaoAuthUrl = UriComponentsBuilder
					.fromUriString("https://kauth.kakao.com/oauth/authorize")
					.queryParam("response_type", "code")
					.queryParam("client_id", clientId)
					.queryParam("redirect_uri", redirectUri)
					.build()
					.toUriString();

			throw new RedirectRequiredException(kakaoAuthUrl);
		}

		// 카카오 사용자 정보 조회
		KakaoUserInfoResponseDto kakaoUser = kakaoOAuthClient.getUserInfo(accessToken);

        String rawEmail = kakaoUser.getKakaoAccount().getEmail();
        String nickname = kakaoUser.getKakaoAccount().getProfile().getNickName();
        String profileImageUrl = kakaoUser.getKakaoAccount().getProfile().getProfileImageUrl();
        String kakaoId = String.valueOf(kakaoUser.getId());

        String safeEmail = (rawEmail == null || rawEmail.isBlank())
                ? "kakao_" + kakaoId + "@placeholder.kakao"
                : rawEmail;

        final String email = safeEmail;

        String randomPassword = UUID.randomUUID().toString();

        String encodedPassword = passwordEncoder.encode(randomPassword);

        return userJpaRepository.findByEmail(email)
                .orElseGet(() -> userJpaRepository.save(
                        User.builder()
                                .kakaoId(kakaoId)
                                .email(email)
                                .password(encodedPassword)
                                .name(nickname)
                                .profileImage(profileImageUrl)
                                .provider(Provider.KAKAO)
                                .build()
                ));

    }

    @Override
    public boolean supports(String type) {
        return "kakao".equalsIgnoreCase(type);
    }
}