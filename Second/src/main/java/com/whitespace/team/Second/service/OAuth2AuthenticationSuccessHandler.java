package com.whitespace.team.Second.service;

import com.whitespace.team.Second.entity.User;
import com.whitespace.team.Second.entity.User.AuthProvider;
import com.whitespace.team.Second.repository.UserRepository;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.security.oauth2.core.user.OAuth2User;
import org.springframework.security.web.authentication.SimpleUrlAuthenticationSuccessHandler;
import org.springframework.stereotype.Component;

import java.io.IOException;
import java.util.Map;

@Component
@RequiredArgsConstructor
public class OAuth2AuthenticationSuccessHandler extends SimpleUrlAuthenticationSuccessHandler {

    private final JwtTokenProvider jwtTokenProvider;
    private final UserRepository userRepository;

    // Flutter deep link scheme — change "myapp" to your actual Flutter app scheme
    private static final String FLUTTER_DEEP_LINK = "myapp://auth/callback";

    @Override
    public void onAuthenticationSuccess(HttpServletRequest request,
                                        HttpServletResponse response,
                                        Authentication authentication) throws IOException {
        OAuth2User oAuth2User = (OAuth2User) authentication.getPrincipal();
        Map<String, Object> attributes = oAuth2User.getAttributes();

        // Identify the provider from the registered client ID
        String registrationId = request.getRequestURI()
                .contains("google") ? "GOOGLE"
                : request.getRequestURI().contains("github") ? "GITHUB"
                : "FACEBOOK";

        String providerId = switch (registrationId) {
            case "GITHUB" -> String.valueOf(attributes.get("id"));
            case "FACEBOOK" -> (String) attributes.get("id");
            default -> (String) attributes.get("sub"); // Google
        };

        User user = userRepository
                .findByProviderAndProviderId(AuthProvider.valueOf(registrationId), providerId)
                .orElseThrow(() -> new RuntimeException("User not found after OAuth2 login"));

        String token = jwtTokenProvider.generateToken(user.getId(), user.getEmail());

        // Redirect to Flutter deep link with JWT as query param
        String redirectUrl = FLUTTER_DEEP_LINK + "?token=" + token;
        getRedirectStrategy().sendRedirect(request, response, redirectUrl);
    }
}
