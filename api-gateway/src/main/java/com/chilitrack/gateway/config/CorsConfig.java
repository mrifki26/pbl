package com.chilitrack.gateway.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.CorsRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@Configuration
public class CorsConfig implements WebMvcConfigurer {

	private final String[] allowedOriginPatterns;

	public CorsConfig(
			@Value("${gateway.cors.allowed-origin-patterns:http://34.231.237.42:*,http://34.231.237.42:8085,http://localhost:*,http://127.0.0.1:*}")
			String allowedOriginPatterns
	) {
		this.allowedOriginPatterns = allowedOriginPatterns.split(",");
	}

	@Override
	public void addCorsMappings(CorsRegistry registry) {
		registry.addMapping("/api/**")
				.allowedOriginPatterns(allowedOriginPatterns)
				.allowedMethods("GET", "POST", "PUT", "DELETE", "OPTIONS")
				.allowedHeaders("Authorization", "Content-Type", "Accept")
				.maxAge(3600);
	}
}
