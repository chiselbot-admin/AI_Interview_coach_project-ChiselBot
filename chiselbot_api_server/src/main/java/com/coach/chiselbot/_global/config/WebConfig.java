package com.coach.chiselbot._global.config;

import com.coach.chiselbot._global.config.jwt.JwtInterceptor;
import com.coach.chiselbot._global.config.session.AdminLoginInterceptor;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.CorsRegistry;
import org.springframework.web.servlet.config.annotation.InterceptorRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@Configuration
@RequiredArgsConstructor
public class WebConfig implements WebMvcConfigurer {

	private final JwtInterceptor jwtInterceptor;
	private final AdminLoginInterceptor adminLoginInterceptor;

	@Override
	public void addInterceptors(InterceptorRegistry registry) {
		registry.addInterceptor(jwtInterceptor)
				.addPathPatterns("/api/**")
				.excludePathPatterns("/api/users/signup", "/api/users/login/**", "/api/interview/coach/**",
						"/api/auth/email/**",
						"/api/interview/**", "/api/notice/**",
						"/api/users/find-email/**", "/api/users/find-password/**", "/api/users/reset-password/**"
				);
		registry.addInterceptor(adminLoginInterceptor)
				.addPathPatterns("/", "/admin/**")
				.excludePathPatterns(
						"/login",
						"/logout"
				);
	}

	@Override
	public void addCorsMappings(CorsRegistry registry) {
		registry.addMapping("/**")
				.allowedOrigins("*")
				.allowedMethods("*");
	}
}
