<?php
use Monolog\Handler\FingersCrossedHandler;
use Monolog\Handler\StreamHandler;
use Monolog\Logger;
use Monolog\Processor\TagProcessor;
use Monolog\Formatter\LogstashFormatter;
use Symfony\Component\EventDispatcher\EventDispatcher;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;

require_once __DIR__ . '/../vendor/autoload.php';

$app          = new Silex\Application();
$app['debug'] = true;

/**
 * A very basic endpoint allowing us to demo how logstash can parse nginx access logs
 */
$app->get(
    '/', function () use ($app) {
    return 'Hello - I am generating logs as we speak!';
}
);

/**
 * This endpoint produces either a succesfull response or one of a few predefined errors.
 * It allows us to demo logstash's ability to surface errors from logs.
 *
 * Errors include a 404, a 500 and a sucesfull but latent request.
 */
$app->get(
    '/flappy', function (Request $req) use ($app) {

    $option = rand(0, 3);

    switch ($option) {
        case 0:
            $response = new Response("NOT FOUND", 404);
            break;
        case 1:
            $response = new Response("Something terrible has happened", 500);
            break;
        case 2:
            sleep(3);
            $response = new Response("Slow response");
            break;
        case 3:
            $response = new Response("Normal response");
            break;
    }

    return $response;
}
);

$app->get(
    '/fingerscrossed', function (Request $req) use ($app) {

    // Pick up the required log level from the environment
    $logEnv     = getenv("LOG_LEVEL");
    $debugLevel = empty($logLevel) ? $logEnv : Logger::WARNING;

    // *** Application Log
    // We use this log to log interactions with the code. Eg - DB connections, queries, api calls etc.
    // Creating a "fingers crossed" handler allows us to collect debug / info messages but only persist the
    // messages to disc is we encounter a log at the severity level in the LOG_LEVEL environment variable.
    // Why not just hard code to Logger::Warning? Because we can use LOG_LEVEL to force debugging on a
    // host by host basis if we require.
    $appLog           = new Logger('AppLog');
    $appStreamHandler = new StreamHandler('/var/log/app.log', Logger::DEBUG);
    $appStreamHandler->setFormatter(new LogstashFormatter("helloapp", "application"));

    // Use the Varnish ID

    $id = $req->headers->get("X_VARNISH", uniqid("req-id"));
    $appLog->pushProcessor(new TagProcessor(['request-id' => $id]));

    $appLog->pushHandler(new FingersCrossedHandler($appStreamHandler, $debugLevel));

    // In reality this is spread through controllers, models, services etc

    $appLog->debug("Doing somthing bootstrappy");
    $appLog->debug("Bootstrap complete");
    $appLog->debug("Calling data source");
    $appLog->debug("Doing query on a remote web service");

    // If something goes wrong we get all the debug messages + warning
    // If not we get no messages
    if (rand(0, 1) === 1) {
        sleep(2);
        $appLog->warning("Database retry due to connection issue");

        return new Response("Slow Response", 200);
    } else {
        $appLog->debug("Returning response");

        return new Response("Fast Response", 200);
    }
}
);

/**
 * A demo showing how Logstash can surface interesting events from your application log.
 */
$app->get(
    '/register', function (Request $req) use ($app) {

    //*** Business Events Log
    // We use this log to log all events - Eg Registrations, Purchases, Logins, Password Resets
    $busLog           = new Logger('BusLog');
    $busStreamHandler = new StreamHandler('/var/log/bus.log', Logger::INFO);
    $busStreamHandler->setFormatter(new LogstashFormatter("helloapp", "business"));
    $busLog->pushHandler($busStreamHandler);

    $dispatcher = new EventDispatcher();

    // A more advanced implementation could use a subscriber rather than adhock listeners.

    $dispatcher->addListener(
        "business.registration.pre", function () use ($busLog) {

        // Fired before a customer registers
        $busLog->info("Customer registering");
    }
    );

    $dispatcher->addListener(
        "business.registration.post", function () use ($busLog) {

        // Fires after a customer has registered
        $busLog->info("Customer registered");
    }
    );

    // In reality these events are dispatched from deep within your domain layer
    $dispatcher->dispatch("business.registration.pre");
    $dispatcher->dispatch("business.registration.post");

    return new Response("Registered!", 201);
}
);

$app->run();