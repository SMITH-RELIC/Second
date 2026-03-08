package com.whitespace.team.Second.service;

import com.whitespace.team.Second.entity.User;
import com.whitespace.team.Second.entity.User.AuthProvider;
import com.whitespace.team.Second.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.oauth2.client.userinfo.DefaultOAuth2UserService;
import org.springframework.security.oauth2.client.userinfo.OAuth2UserRequest;
import org.springframework.security.oauth2.core.OAuth2AuthenticationException;
import org.springframework.security.oauth2.core.user.OAuth2User;
import org.springframework.stereotype.Service;

import java.util.Map;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class CustomOAuth2UserService extends DefaultOAuth2UserService {

    private final UserRepository userRepository;

    @Override
    public OAuth2User loadUser(OAuth2UserRequest userRequest) throws OAuth2AuthenticationException {
        OAuth2User oAuth2User = super.loadUser(userRequest);

        String registrationId = userRequest.getClientRegistration().getRegistrationId().toUpperCase();
        AuthProvider provider = AuthProvider.valueOf(registrationId);
        Map<String, Object> attributes = oAuth2User.getAttributes();

        String providerId;
        String email;
        String name;
        String avatarUrl;

        switch (provider) {
            case GITHUB -> {
                providerId = String.valueOf(attributes.get("id"));
                email = (String) attributes.getOrDefault("email", providerId + "@github.noemail");
                name = (String) attributes.getOrDefault("name", attributes.get("login"));
                avatarUrl = (String) attributes.get("avatar_url");
            }
            case FACEBOOK -> {
                providerId = (String) attributes.get("id");
                email = (String) attributes.getOrDefault("email", providerId + "@facebook.noemail");
                name = (String) attributes.get("name");
                Map<String, Object> picture = (Map<String, Object>) attributes.get("picture");
                avatarUrl = picture != null ? (String) ((Map<?, ?>) picture.get("data")).get("url") : null;
            }
            default -> { // GOOGLE
                providerId = (String) attributes.get("sub");
                email = (String) attributes.get("email");
                name = (String) attributes.get("name");
                avatarUrl = (String) attributes.get("picture");
            }
        }

        Optional<User> existingUser = userRepository.findByProviderAndProviderId(provider, providerId);

        User user;
        if (existingUser.isPresent()) {
            user = existingUser.get();
            user.setName(name);
            user.setAvatarUrl(avatarUrl);
        } else {
            user = User.builder()
                    .email(email)
                    .name(name)
                    .avatarUrl(avatarUrl)
                    .provider(provider)
                    .providerId(providerId)
                    .build();
        }

        userRepository.save(user);
        return oAuth2User;
    }
}
