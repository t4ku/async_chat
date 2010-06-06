Feature: User Registration

    In order to signup,
    As a firt-time user,
    I want to create my account and log in
    
    Scenario: Normal Registration
    
        Given I am on the new user page
        And I fill in "login" with "test"
        And I fill in "name" with "あいうえお"
        And I fill in "email" with "test_user@example.com"
        When I press "register"
        Then I should see "registered"