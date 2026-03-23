package ma.safar.morocco.config;

import lombok.extern.slf4j.Slf4j;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.task.TaskExecutor;
import org.springframework.scheduling.annotation.EnableAsync;
import org.springframework.scheduling.concurrent.ThreadPoolTaskExecutor;

/**
 * AsyncConfig
 * Configuration pour l'exécution asynchrone des tâches (logs d'audit, emails, etc.)
 * Améliore les performances en parallélisant les opérations non-critiques
 */
@Configuration
@EnableAsync
@Slf4j
public class AsyncConfig {

    /**
     * Configure un ThreadPoolTaskExecutor pour les tâches asynchrones
     * - Core threads: 2 (threads toujours actifs)
     * - Max threads: 5 (maximum concurrent)
     * - Queue: 100 (queue size avant rejection)
     */
    @Bean(name = "taskExecutor")
    public TaskExecutor taskExecutor() {
        ThreadPoolTaskExecutor executor = new ThreadPoolTaskExecutor();
        executor.setCorePoolSize(2);
        executor.setMaxPoolSize(5);
        executor.setQueueCapacity(100);
        executor.setThreadNamePrefix("Async-");
        executor.setAwaitTerminationSeconds(60);
        executor.setWaitForTasksToCompleteOnShutdown(true);
        executor.initialize();
        
        log.info("Async TaskExecutor configured: corePoolSize=2, maxPoolSize=5");
        return executor;
    }
}
