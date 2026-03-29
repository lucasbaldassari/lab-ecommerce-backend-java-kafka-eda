package com.ecommerce.billing_service.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/billing")
public class IndexController {

    @GetMapping
    public String index() {
        return "billing-service is running";
    }

}
