package com.coach.chiselbot.domain.kakao;

import com.coach.chiselbot._global.config.jwt.JwtTokenProvider;
import com.coach.chiselbot.domain.user.User;
import com.coach.chiselbot.domain.user.dto.UserRequestDTO;
import com.coach.chiselbot.domain.user.login.LoginStrategy;
import com.coach.chiselbot.domain.user.login.LoginStrategyFactory;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.util.UriComponentsBuilder;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;

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
}
