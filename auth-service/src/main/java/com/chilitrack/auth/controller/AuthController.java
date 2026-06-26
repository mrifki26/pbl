package com.chilitrack.auth.controller;

import com.chilitrack.auth.dto.*;
import com.chilitrack.auth.entity.AuthUser;
import com.chilitrack.auth.repository.AuthUserRepository;
import com.chilitrack.auth.security.JwtUtil;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/auth")
public class AuthController {

    private final AuthUserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtUtil jwtUtil;

    public AuthController(AuthUserRepository userRepository, PasswordEncoder passwordEncoder, JwtUtil jwtUtil) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
        this.jwtUtil = jwtUtil;
    }

    @PostMapping("/register")
    public ResponseEntity<?> register(@RequestBody LoginRequest req) {

        if (req == null || req.username == null || req.username.isBlank()
                || req.password == null || req.password.isBlank()) {
            return ResponseEntity.badRequest()
                    .body(Map.of("message", "Username dan password wajib diisi"));
        }

        String username = req.username.trim();

        if (userRepository.existsByUsername(username)) {
            return ResponseEntity.status(HttpStatus.CONFLICT)
                    .body(Map.of("message", "Username sudah terdaftar"));
        }

        AuthUser user = new AuthUser();
        user.setUsername(username);
        user.setPassword(passwordEncoder.encode(req.password));
        userRepository.save(user);

        String token = jwtUtil.generateToken(username);
        return ResponseEntity.ok(new LoginResponse(token));
    }

    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody LoginRequest req) {

        if (req == null || req.username == null || req.password == null) {
            return ResponseEntity.badRequest()
                    .body(Map.of("message", "Username dan password wajib diisi"));
        }

        return userRepository.findByUsername(req.username.trim())
                .filter(user -> passwordEncoder.matches(req.password, user.getPassword()))
                .<ResponseEntity<?>>map(user -> {
                    String token = jwtUtil.generateToken(user.getUsername());
                    return ResponseEntity.ok(new LoginResponse(token));
                })
                .orElseGet(() -> ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                        .body(Map.of("message", "Username atau password salah")));

    }
}
