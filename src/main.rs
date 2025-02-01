use thirtyfour::prelude::*;
use tokio::time::{sleep, Duration};

#[tokio::main]
async fn main() -> WebDriverResult<()> {
    println!("Connecting to Selenium...");

    // Connect to Selenium
    let caps = DesiredCapabilities::chrome();
    println!("Attempting to connect to WebDriver...");
    let driver = match WebDriver::new("http://chrome:4444", caps).await {
        Ok(driver) => {
            println!("Connected to Selenium successfully!");
            driver
        }
        Err(e) => {
            eprintln!("Failed to connect to Selenium: {}", e);
            return Err(e);
        }
    };

    println!("Navigating to https://www.rust-lang.org...");

    // Navigate to a website
    if let Err(e) = driver.goto("https://www.rust-lang.org").await {
        eprintln!("Failed to navigate to the website: {}", e);
        driver.quit().await?;
        return Err(e);
    }

    println!("Waiting for the page to load...");
    sleep(Duration::from_secs(2)).await;

    // Print the title
    match driver.title().await {
        Ok(title) => println!("Page title: {}", title),
        Err(e) => eprintln!("Failed to get page title: {}", e),
    }

    println!("Closing the browser...");

    // Close the browser
    if let Err(e) = driver.quit().await {
        eprintln!("Failed to close the browser: {}", e);
        return Err(e);
    }

    println!("Browser closed. Exiting...");
    Ok(())
}