package com.ecommerce.catalog_service.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/catalog")
public class IndexController {

    @GetMapping
    public String index() {
        return "catalog-service is running";
    }

}
