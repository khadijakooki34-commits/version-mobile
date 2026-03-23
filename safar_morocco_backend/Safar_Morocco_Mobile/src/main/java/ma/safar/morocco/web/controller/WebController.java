package ma.safar.morocco.web.controller;

import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import ma.safar.morocco.destination.entity.Destination;
import ma.safar.morocco.destination.repository.DestinationRepository;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.util.UriComponentsBuilder;

import java.io.IOException;

@Controller
@RequiredArgsConstructor
public class WebController {

    private final DestinationRepository destinationRepository;

    @GetMapping({"/", "/index"})
    public String index(Model model) {
        model.addAttribute("destinations", destinationRepository.findAll());
        return "index";
    }

    @GetMapping("/destinations")
    public String destinations(Model model) {
        model.addAttribute("destinations", destinationRepository.findAll());
        return "destinations";
    }

    @GetMapping("/destinations/{id}")
    public String destinationDetail(@PathVariable Long id, Model model) {
        Destination dest = destinationRepository.findById(id).orElse(null);
        model.addAttribute("destination", dest);
        return "destination";
    }

    @GetMapping("/login")
    public void login(@RequestParam(required = false) String error,
                     HttpServletResponse response) throws IOException {
        // If there's an OAuth error, redirect to Flutter
        if (error != null) {
            String frontendUrl = System.getenv("FRONTEND_URL");
            if (frontendUrl == null || frontendUrl.isEmpty()) {
                frontendUrl = "http://localhost:57977";
            }
            
            String targetUrl = UriComponentsBuilder
                    .fromUriString(frontendUrl + "/oauth-callback")
                    .queryParam("error", "oauth2_failed")
                    .queryParam("message", error)
                    .build()
                    .toUriString();
            
            response.sendRedirect(targetUrl);
            return;
        }
        
        // If no error, show login page (for non-OAuth logins)
        response.sendRedirect("/");
    }

    @GetMapping("/register")
    public String register() {
        return "register";
    }

    @GetMapping("/profile")
    public String profile() {
        return "profile";
    }
}
