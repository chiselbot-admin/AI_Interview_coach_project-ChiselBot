package com.coach.chiselbot.domain.kakao;

import com.coach.chiselbot._global.config.jwt.JwtTokenProvider;
import com.coach.chiselbot._global.dto.CommonResponseDto;
import com.coach.chiselbot.domain.user.User;
import com.coach.chiselbot.domain.user.dto.UserRequestDTO;
import com.coach.chiselbot.domain.user.login.LoginStrategy;
import com.coach.chiselbot.domain.user.login.LoginStrategyFactory;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.util.UriComponentsBuilder;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.Map;

@RestController
@RequiredArgsConstructor
@RequestMapping("/oauth/kakao")
public class KakaoOAuthController {

    @Value("${oauth.kakao.client-id}")
    private String clientId;

    @Value("${oauth.kakao.redirect-uri}")
    private String redirectUri;

    private final LoginStrategyFactory loginStrategyFactory;
    private final JwtTokenProvider jwtTokenProvider;

    @GetMapping("/login")
    public void redirectToKakao(HttpServletResponse response) throws IOException {
        String kakaoAuthUrl = UriComponentsBuilder.fromUriString("https://kauth.kakao.com/oauth/authorize")
                .queryParam("response_type", "code")
                .queryParam("client_id", clientId)
                .queryParam("redirect_uri",redirectUri)
                .build()
                .toUriString();

        response.sendRedirect(kakaoAuthUrl);
    }

    @GetMapping("/callback")
    public void kakaoCallback(@RequestParam String code, HttpServletResponse response) throws IOException {
        LoginStrategy strategy = loginStrategyFactory.findStrategy("kakao");

        UserRequestDTO.Login dto = new UserRequestDTO.Login();
        dto.setAuthCode(code);

        User user = strategy.login(dto);
        String token = jwtTokenProvider.createToken(user);

        String encodedToken = URLEncoder.encode(token, StandardCharsets.UTF_8);

        response.sendRedirect("myapp:login?token=" + encodedToken);
    }

	/**
	 * Flutter SDK를 통한 카카오 로그인
	 * POST /oauth/kakao/token
	 */
	@PostMapping("/token")
	public ResponseEntity<CommonResponseDto<?>> loginWithAccessToken(
			@RequestBody Map<String, String> request) {

		String accessToken = request.get("accessToken");

		if (accessToken == null || accessToken.isBlank()) {
			return ResponseEntity.badRequest()
					.body(CommonResponseDto.error("accessToken이 필요합니다."));
		}

		try {
			LoginStrategy strategy = loginStrategyFactory.findStrategy("kakao");

			UserRequestDTO.Login dto = new UserRequestDTO.Login();
			dto.setAccessToken(accessToken);

			User user = strategy.login(dto);
			String token = jwtTokenProvider.createToken(user);

			Map<String, Object> responseData = Map.of(
					"userId", user.getId().toString(),
					"name", user.getName(),
					"token", token,
					"profileImageUrl", user.getProfileImage()
			);

			return ResponseEntity.ok(CommonResponseDto.success(responseData, "로그인 성공"));

		} catch (Exception e) {
			return ResponseEntity.status(401)
					.body(CommonResponseDto.error("카카오 로그인 실패: " + e.getMessage()));
		}
	}

}
