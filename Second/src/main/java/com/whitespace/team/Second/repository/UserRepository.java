package com.whitespace.team.Second.repository;

import com.whitespace.team.Second.entity.User;
import com.whitespace.team.Second.entity.User.AuthProvider;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.Optional;

public interface UserRepository extends JpaRepository<User, Long> {
    Optional<User> findByEmail(String email);
    Optional<User> findByProviderAndProviderId(AuthProvider provider, String providerId);
    boolean existsByEmail(String email);
}
