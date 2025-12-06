package com.example.demo.config;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import software.amazon.awssdk.auth.credentials.DefaultCredentialsProvider;
import software.amazon.awssdk.regions.Region;
import software.amazon.awssdk.services.secretsmanager.SecretsManagerClient;
import software.amazon.awssdk.services.secretsmanager.model.GetSecretValueRequest;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Profile;
import static software.amazon.jdbc.plugin.AwsSecretsManagerConnectionPlugin.REGION_PROPERTY;
import static software.amazon.jdbc.plugin.AwsSecretsManagerConnectionPlugin.SECRET_ID_PROPERTY;

import javax.sql.DataSource;
import com.zaxxer.hikari.HikariDataSource;

@Configuration
public class DataSourceConfig {
    // REGION_PROPERTY.setDefaultValue("us-east-1");
    // SECRET_ID_PROPERTY.setDefaultValue("postgres-db-secret");

/* 

    @Value("${spring.datasource.url}")
    private String jdbcUrl;

    @Value("${spring.datasource.username}")
    private String username;

    @Value("${spring.datasource.password}")
    private String password;

    

    @Bean
    @Profile("aws")
    public DataSource dataSource() throws Exception {
        String secretName = "postgres-db-secret";

        SecretsManagerClient client = SecretsManagerClient.builder()
                .region(Region.of("us-east-1"))
                .credentialsProvider(DefaultCredentialsProvider.create())
                .build();

        String secretJson = client.getSecretValue(GetSecretValueRequest.builder()
                .secretId(secretName)
                .build()).secretString();

        JsonNode secret = new ObjectMapper().readTree(secretJson);

        HikariDataSource ds = new HikariDataSource();
        ds.setJdbcUrl("jdbc:postgresql://" +
                secret.get("host").asText() + ":" +
                secret.get("port").asText() + "/" +
                secret.get("dbname").asText());
        ds.setUsername(secret.get("username").asText());
        ds.setPassword(secret.get("password").asText());
        ds.setDriverClassName("org.postgresql.Driver");


        return ds;
    }

    @Bean
    @Profile("local")
    public DataSource dataSourceLocal() throws Exception {
        

        HikariDataSource ds = new HikariDataSource();
        ds.setJdbcUrl(jdbcUrl);
        ds.setUsername(username);
        ds.setPassword(password);
        ds.setQu
        ds.setDriverClassName("org.postgresql.Driver");

        return ds;
    } */
}