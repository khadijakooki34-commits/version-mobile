package ma.safar.morocco.config;

import ma.safar.morocco.destination.entity.Destination;
import ma.safar.morocco.destination.repository.DestinationRepository;
import ma.safar.morocco.event.entity.EvenementCulturel;
import ma.safar.morocco.event.repository.EvenementCulturelRepository;
import ma.safar.morocco.media.entity.Media;
import ma.safar.morocco.review.entity.Avis;
import ma.safar.morocco.review.repository.AvisRepository;
import ma.safar.morocco.user.entity.Utilisateur;
import ma.safar.morocco.user.repository.UtilisateurRepository;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.transaction.annotation.Transactional;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.HashMap;

@Configuration
public class DataInitializer {

        private static final Logger logger = LoggerFactory.getLogger(DataInitializer.class);

        private final UtilisateurRepository userRepository;
        private final DestinationRepository destinationRepository;
        private final AvisRepository reviewRepository;
        private final EvenementCulturelRepository eventRepository;
        private final PasswordEncoder encoder;

        public DataInitializer(UtilisateurRepository userRepository,
                        DestinationRepository destinationRepository,
                        AvisRepository reviewRepository,
                        EvenementCulturelRepository eventRepository,
                        PasswordEncoder encoder) {
                this.userRepository = userRepository;
                this.destinationRepository = destinationRepository;
                this.reviewRepository = reviewRepository;
                this.eventRepository = eventRepository;
                this.encoder = encoder;
        }

        @Bean
        @Transactional
        CommandLineRunner initDatabase() {
                return args -> {
                        try {

                                /*
                                 * =======================
                                 * 1. CREATE USERS
                                 * =======================
                                 */
                                if (!userRepository.existsByEmail("admin@safar.com")) {
                                        Utilisateur admin = Utilisateur.builder()
                                                        .nom("Admin")
                                                        .email("admin@safar.com")
                                                        .motDePasseHache(encoder.encode(System.getenv("ADMIN_PASS") != null ? System.getenv("ADMIN_PASS") : "SecureSafarMrc2026!Adm"))
                                                        .role("ADMIN")
                                                        .telephone("+212600000000")
                                                        .langue("Morocco") 
                                                        .description("System Administrator for Safar Morocco.")
                                                        .actif(true)
                                                        .compteBloquer(false)
                                                        .build();
                                        userRepository.save(admin);
                                }

                                if (!userRepository.existsByEmail("user@safar.com")) {
                                        Utilisateur user = Utilisateur.builder()
                                                        .nom("John Doe") 
                                                        .email("user@safar.com")
                                                        .motDePasseHache(encoder.encode(System.getenv("USER_PASS") != null ? System.getenv("USER_PASS") : "SecureSafarMrc2026!Usr"))
                                                        .role("USER")
                                                        .telephone("+15550123")
                                                        .langue("USA")
                                                        .description("Travel enthusiast exploring Morocco.")
                                                        .actif(true)
                                                        .compteBloquer(false)
                                                        .build();
                                        userRepository.save(user);
                                }

                                Utilisateur normalUser = userRepository.findByEmail("user@safar.com").orElseThrow();
                                /*
                                 * =======================
                                 * 2. CREATE DESTINATIONS
                                 * =======================
                                 */
                                List<Destination> destinations = new ArrayList<>();
                                destinations.add(createDestination("Jemaa el-Fnaa", "Célèbre place et marché.",
                                                "Marrakech", "Cultural", 31.6258, -7.9891,
                                                "https://images.openai.com/static-rsc-3/4oMlZ5fHrx1GAh246lmd7hDI8EiHK8zCRcb14tTvYq9PUvGmFUUkgIg6UfwsrMAeypv8Qh2dGKWJK24qEi5cOwZeF0KS2g3Zq8SmdpV_LdY?purpose=fullsize&v=1",
                                                "La place Jemaa el-Fnaa est le cœur battant de Marrakech depuis la fondation de la ville au XIe siècle par les Almoravides. Historiquement, elle servait de lieu de justice publique où les criminels étaient décapités, d'où son nom macabre qui signifierait \"assemblée des morts\". Au fil des siècles, cet espace s'est transformé en un carrefour de commerce et de rencontres culturelles, attirant des caravaniers du monde entier. Son importance culturelle est telle que l'UNESCO l'a déclarée chef-d'œuvre du patrimoine oral et immatériel de l'humanité. Aujourd'hui, elle perpétue les traditions marocaines à travers ses conteurs, ses musiciens Gnaouas, et ses charmeurs de serpents, représentant un véritable théâtre en plein air qui illustre la richesse et la diversité du patrimoine marocain."));
                                destinations.add(createDestination("Hassan II Mosque", "Plus grande mosquée du Maroc.",
                                                "Casablanca", "Religious", 33.608, -7.632,
                                                "https://images.openai.com/static-rsc-3/NgTc0N8_ERJ20iUdgG9ZwfSn0lJ3A1RqPZCLMUDzEAvYjyFfakYWOYGLLcITEJPGwjcvLb9yK6_DXlyPaFaKc6kx699pSMHjrBJ2-U5sg3w?purpose=fullsize&v=1",
                                                "La Mosquée Hassan II, érigée sur les flots de l'Océan Atlantique à Casablanca, est un chef-d'œuvre monumental de l'architecture islamique contemporaine. Achevée en 1993 sur la demande de feu le Roi Hassan II, elle symbolise la renaissance de l'artisanat traditionnel marocain allié aux technologies modernes. Des milliers d'artisans venus de tout le royaume ont contribué à la création de ses zelliges intriqués, de ses plafonds en bois de cèdre sculpté, et de son stuc délicat. Historiquement, elle marque la volonté de doter la capitale économique d'un monument spirituel d'envergure internationale. Son minaret, s'élevant à 210 mètres, fut longtemps le plus haut du monde."));
                                destinations.add(createDestination("Ait Ben Haddou", "Site du patrimoine mondial de l'UNESCO.",
                                                "Ouarzazate", "Historical", 31.047, -7.1306,
                                                "https://images.openai.com/static-rsc-3/PsvMnYdCkrxUuGwDw1Lnb8SKvMfWqed_wad_0XfZxHL9W4U82igx5uAAGlm1lmQod1xJQL_SswvBgREqosPJa7yv1Pr2BIH6i7KygyPcYvs?purpose=fullsize&v=1",
                                                "Aït-ben-Haddou est un ksar du Maroc inscrit sur la liste du patrimoine mondial de l'UNESCO depuis 1987. Situé dans la province de Ouarzazate, c'est un exemple frappant de l'architecture sud-marocaine traditionnelle. Ce village fortifié, constitué d'un ensemble de bâtiments de terre entourés de murailles, était autrefois une étape importante pour les caravanes reliant le Sahara à Marrakech. Sa structure compacte, ses tours d'angle et ses motifs décoratifs en brique crue témoignent du génie architectural des populations présahariennes."));
                                destinations.add(createDestination("Merzouga Desert", "Porte du désert du Sahara.",
                                                "Errachidia", "Nature", 31.0994, -4.0127,
                                                "https://images.openai.com/static-rsc-3/QSwTCw_J-gISrD2F5XLFmLfBk9bpsBNqiMEa9q3frLYK_iU_KTOcnYsFG7zCLSUV8KWnJgZzwZq7zueRMArW0DpNPCZTNiVvjFIvAF_5ebI?purpose=fullsize&v=1",
                                                "Le désert de Merzouga, avec ses imposantes dunes d'Erg Chebbi qui peuvent atteindre jusqu'à 150 mètres de hauteur, est une merveille géologique du sud-est marocain. Historiquement, cette région a été habitée par des tribus nomades amazighes qui ont développé une connaissance intime des écosystèmes arides et des routes des oasis. La légende locale raconte que ces dunes gigantesques furent façonnées par Dieu pour punir une riche famille locale qui refusa d'abriter un pauvre pèlerin."));
                                destinations.add(createDestination("Ouzoud Waterfalls", "Fameuses cascades dans l'Atlas.",
                                                "Azilal", "Nature", 32.0142, -6.7189,
                                                "https://images.openai.com/static-rsc-3/tUf-hSbp7EoJfy0auuvI3MiB6O2c55fJFKKe_pWZzNCuu_5WwR2uk8ozJZxLq0yfDY_xB8zkzig-rcj6TB96ea0frKPwnOcHzTrYSfjh48w?purpose=fullsize&v=1",
                                                "Les cascades d'Ouzoud, nichées au cœur des majestueuses montagnes du Moyen Atlas, constituent l'une des attractions naturelles les plus spectaculaires d'Afrique du Nord, s'écrasant férocement d'une hauteur impressionnante de 110 mètres. Ayant le sens d'olive en amazigh, Ouzoud témoigne de l'importance de la culture de l'olivier qui a façonné la vie économique des Berbères de la région depuis des générations."));
                                destinations.add(createDestination("Fes El Bali", "Ancienne médina de Fès.", "Fès",
                                                "Cultural", 34.0331, -5.0003,
                                                "https://www.story-rabat.com/wp-content/uploads/2024/05/fes-el-bali1.webp",
                                                "Fès el-Bali, la plus ancienne médina fortifiée de Fès, a été fondée à la fin du VIIIe siècle par la dynastie idrisside. Avec son incroyable réseau de près de 9 000 ruelles entremêlées, ce chef-d'œuvre urbain est reconnu comme la plus vaste zone piétonne au monde et classé au patrimoine mondial de l'UNESCO. Historiquement, Fès a été le cœur intellectuel, culturel et spirituel révolutionnaire du Maroc."));
                                destinations.add(createDestination("Todgha Gorges", "Canyon spectaculaire.", "Tinghir",
                                                "Nature", 31.5873, -5.5764,
                                                "https://www.travel-exploration.com/images/Todra-Gorge-Travel-Exploration-Morocco_17vshgxu7v8z2.jpeg",
                                                "Les gorges du Todgha (ou Todra) se composent de falaises de calcaire rouge monumentales atteignant jusqu'à 300 mètres de hauteur sur les flancs orientaux des montagnes du Haut Atlas. Taillées séculairement par le cours éponyme, l'immense val de faille représentait historiquement un sentier stratégique difficile pour les marchands arabes et berbères transsahariens."));
                                destinations.add(createDestination("Dades Valley", "Formations rocheuses et vallées.",
                                                "Boumalne Dades", "Nature", 31.4575, -5.9937,
                                                "https://www.morocco-ecotours.com/wp-content/uploads/2019/05/THE-DADES-VALLEY-FROM-OUARZAZATE.jpg",
                                                "La spectaculaire Vallée du Dadès, populairement surnommée \"la vallée des mille kasbahs\", se fraie un passage au milieu d'étonnants affleurements rocheux, où dominent les mystérieux rochers ronds de la fameuse chaîne \"Doigts de singe\"."));
                                destinations.add(createDestination("Essaouira Medina", "Ville côtière fortifiée.",
                                                "Essaouira", "Cultural", 31.5085, -9.7595,
                                                "https://tse1.mm.bing.net/th/id/OIP.z42bHPRS20luELBtPWucuwHaE8?w=474&h=379&c=7&p=0",
                                                "La charmante médina d'Essaouira, anciennement connue sous l'illustre nom de Mogador, est un joyau côtier fortifié réputé pour la mélodie de ses puissants vents marins et sa diversité culturelle vibrante. Édifiée à la fin du XVIIIe siècle par de fins architectes européens comme Théodore Cornut."));
                                destinations.add(createDestination("Rabat City Center", "La capitale du Maroc.",
                                                "Rabat", "Cultural", 34.0209, -6.8416,
                                                "https://tse1.mm.bing.net/th/id/OIP.xSz7hiAKx9qacg7XykS_dwHaE8?w=474&h=379&c=7&p=0",
                                                "Rabat, la digne capitale politique et administrative du Royaume du Maroc, jouit d'une captivante fusion d'héritage médiéval musulman et de splendides plans d'urbanisme colonial harmonieux. Bâtie sérieusement dès le XIIe siècle par la téméraire dynastie almohade sous l'égide du calife conquérant Yaqub al-Mansur."));
                                destinations.add(createDestination("Agadir Beach", "Ville côtière moderne et station balnéaire.",
                                                "Agadir", "Nature", 30.4278, -9.5981,
                                                "https://www.barcelo.com/guia-turismo/wp-content/uploads/2024/09/ok-playas-de-agadir.jpg",
                                                "La splendeur de la cité balnéaire d'Agadir, située le long du littoral atlantique éclatant du Maroc, présente une résilience urbaine et humaine exceptionnellement touchante. Après avoir été détruite lors d'un séisme cataclysmique en février 1960, la municipalité fut entièrement repensée et vaillamment surélevée vers un modernisme visionnaire."));
                                destinations.add(createDestination("Kelaat Mgouna", "La Vallée des Roses.",
                                                "Kelaat Mgouna", "Nature", 31.2381, -6.1264,
                                                "https://dynamic-media-cdn.tripadvisor.com/media/photo-o/0d/cc/c6/d2/la-vallee-des-rose.jpg?w=600&h=-1&s=1",
                                                "Kalâat M'Gouna, édifiée poétiquement au creux des contreforts de l'Atlas Central, est internationalement baptisée la fière \"Vallée des Roses\" grâce à un savoir-faire floral émouvant datant du siècle dernier."));
                                destinations.add(createDestination("Sefrou City", "Jardin ville du Maroc.", "Sefrou",
                                                "Nature", 33.829, -4.8329,
                                                "https://aujourdhui.ma/wp-content/uploads/2016/08/sefrou.jpg",
                                                "L'envoûtante Sefrou, qualifiée curieusement de \"la beauté qui protège\", est affectueusement l'une des rarissimes oasis urbaines anciennes résilientes au pied infini des pentes atlantiques."));
                                destinations.add(createDestination("Guelmim Gate", "Porte du désert.", "Guelmim",
                                                "Cultural", 28.987, -10.0574,
                                                "https://static.lematin.ma/files/lematin/images/articles/2021/03/90a8d5194085b18624e2c31105483454.jpg",
                                                "Guelmim, dénommée affectueusement avec honneur et mystère \"la porte du sahara\", constitue globalement la métropole provinciale frontalière majeure d'antan vers l'éternelle aridité de l'énorme bassin atlantique régulier."));
                                destinations.add(createDestination("Laayoune City", "Plus grande ville du Sahara marocain.",
                                                "Laayoune", "Cultural", 27.15, -13.1991,
                                                "https://tse2.mm.bing.net/th/id/OIP.Fsuvp-qsQ5AvmMV5ZU5o8QHaE8?w=474&h=379&c=7&p=0",
                                                "Implantée audacieusement au sein des arides latitudes extraordinaires du majestueux grand Sahara, Laâyoune émergea jadis comme garnison stratégique coloniale conçue par le général espagnol Antonio de Oro dans les années 1930."));
                                destinations.add(createDestination("Imilchil Village", "Village de montagne du Haut Atlas.",
                                                "Imilchil", "Nature", 32.1583, -5.5833,
                                                "https://tse3.mm.bing.net/th/id/OIP.i74I8UQKPR9miDguNbfvJQHaEH?w=474&h=379&c=7&p=0",
                                                "L'humble citadelle légendaire et majestueuse du petit village reculé d'Imilchil est nichée fièrement à plus de 2119 mètres d'altitude au cœur du Haut Atlas central. Les inénarrables mystères de ce lieu résonnent fort, notamment par le mythe mémorable et tragique des amours légendaires de Tislit et Isli."));
                                destinations.add(createDestination("Dakhla Lagoon",
                                                "Paradis pour le kitesurf et les amoureux de la nature.", "Dakhla", "Nature",
                                                23.6841, -15.9579,
                                                "https://tse3.mm.bing.net/th/id/OIP.qCKfiG-jps-hjQyZrdFY1QHaEK?w=474&h=379&c=7&p=0",
                                                "Formidable cap marin de poésie océanographique exquise, la splendide cité de la péninsule de Oued Ed-Dahab, Dakhla, fut majestueusement bâtie durant l'époque hispano-saharienne."));
                                destinations.add(createDestination("Al Hoceima Bay",
                                                "Perle méditerranéenne aux eaux cristallines.", "Al Hoceima",
                                                "Nature", 35.2446, -3.9321,
                                                "https://images.ferryhopper.com/locations/al-hoceima-port-morocco.jpg",
                                                "Bercée aux mélancolies des resplendissantes rives de la Méditerranée, Al Hoceima s'est élevée témérairement sur les pentes montagneuses des redoutables montagnes du Rif."));
                                destinations.add(createDestination("Bin El Ouidane Lake",
                                                "Magnifique lac au cœur de l'Atlas.", "Azilal", "Nature",
                                                32.1333, -6.2833,
                                                "https://cdn.britannica.com/89/144989-050-F66A32CA/Laayoune-Western-Sahara.jpg",
                                                "D'apparence résolument de conte de fées, le séduisant lac majestueux de Bin el Ouidane est une merveille hydrique miraculeusement artificielle, résultant des prouesses d'ingénierie colossales du milieu du XXe siècle."));
                                destinations.add(createDestination("Oualidia Lagoon",
                                                "Village côtier pittoresque et capitale des huîtres.", "Oualidia", "Nature",
                                                32.73, -9.04,
                                                "https://dynamic-media-cdn.tripadvisor.com/media/photo-o/12/d7/d9/dd/die-lagune.jpg?w=900&h=-1&s=1",
                                                "Oualidia, pittoresque lagune paisible dotée d'une éblouissante splendeur, se situe majestueusement sur la côte atlantique. L'histoire fondatrice de cet écrin marin remonte au XVIIe siècle, fortifiée par d'illustres souverains."));
                                destinations.add(createDestination("Azrou Cedar Forest",
                                                "Habitat des singes magots.", "Azrou", "Nature", 33.4417,
                                                -5.2158,
                                                "https://img.freepik.com/premium-photo/azrou-cedar-forest-morocco_480416-507.jpg",
                                                "Imposante et solennelle, l'exubérante forêt de cèdres dorés s'établit au cœur du Moyen Atlas autour d'Azrou. Cette légendaire étendue de conifères multimillénaires demeure un témoin indéniable du lointain passé végétal."));
                                destinations.add(createDestination("Hercules Caves",
                                                "Grotte mythologique surplombant l'Atlantique.", "Tangier", "Historical",
                                                35.76, -5.9392,
                                                "https://www.barcelo.com/guia-turismo/wp-content/uploads/2022/01/cuevas-de-hercules.jpg",
                                                "Les énigmatiques Grottes d'Hercule, à quelques encablures de Tanger, enveloppent de légendes spectaculaires ce cap nord dominant les périlleux détroits."));
                                destinations.add(createDestination("Oukaimeden Resort", "Plus haute station de ski d'Afrique.",
                                                "Marrakech", "Nature", 31.2044, -7.8631,
                                                "https://www.lesjardinsdelamedina.com/blog/wp-content/uploads/2019/11/OUKA%C3%8FMEDEN-678x381.jpg",
                                                "Nichée magnifiquement aux hauts sommets vertigineux des imposantes montagnes du Haut Atlas, à près de 2 600 mètres d'altitude, la sublime Oukaïmeden règne à la fois comme unique et plus haute station de ski du continent africain."));
                                destinations.add(createDestination("Saidia Beach",
                                                "La Perle Bleue de la Méditerranée.", "Berkane", "Nature", 35.0833,
                                                -2.2333,
                                                "https://dynamic-media-cdn.tripadvisor.com/media/photo-o/0a/c2/e8/36/photo-de-la-plage-de.jpg?w=1100&h=1100&s=1",
                                                "Brillamment surnommée familièrement la majestueuse \"Perle Bleue\" de la fière Méditerranée orientale, la sublime station de Saïdia marie somptueusement sa longue plage de sable fin d'or et d'un océan céruléen éblouissant."));
                                destinations.add(createDestination("Asilah Old Town",
                                                "Ville côtière connue pour ses fresques et son art.", "Asilah", "Cultural",
                                                35.4667, -6.0333,
                                                "https://chicmorocco.com/wp-content/uploads/2023/08/vistas-asilah-muralla-1024x683.jpg",
                                                "L'éblouissante Asilah, gracieuse médina lumineuse et immaculée dressée avec hardiesse contre les vagues atlantiques, séduit les pèlerins par sa tranquillité poétique inébranlable."));

                                // Saving all destinations (filtering nulls which mean they already exist)
                                List<Destination> toSave = destinations.stream()
                                                .filter(java.util.Objects::nonNull)
                                                .collect(java.util.stream.Collectors.toList());
                                var savedDestinations = destinationRepository.saveAll(toSave);

                                // Add Reviews
                                if (savedDestinations.size() >= 2) {
                                        Avis r1 = Avis.builder()
                                                        .note(5)
                                                        .commentaire("Amazing place!")
                                                        .auteur(normalUser)
                                                        .destination(savedDestinations.get(0))
                                                        .status("APPROVED")
                                                        .datePublication(LocalDateTime.now())
                                                        .build();

                                        Avis r2 = Avis.builder()
                                                        .note(4)
                                                        .commentaire("Very beautiful.")
                                                        .auteur(normalUser)
                                                        .destination(savedDestinations.get(1))
                                                        .status("APPROVED")
                                                        .datePublication(LocalDateTime.now())
                                                        .build();

                                        reviewRepository.saveAll(List.of(r1, r2));
                                }

                                /*
                                 * =======================
                                 * UPDATE EVENT DATES TO FUTURE (2026)
                                 * =======================
                                 */
                                {
                                        Map<String, int[]> eventDateOffsets = new HashMap<>();
                                        eventDateOffsets.put("Mawazine", new int[] { 30, 38 });
                                        eventDateOffsets.put("Timitar", new int[] { 45, 47 });
                                        eventDateOffsets.put("Fes Sacred Music", new int[] { 60, 68 });
                                        eventDateOffsets.put("Rose Festival", new int[] { 15, 18 });
                                        eventDateOffsets.put("Tanjazz", new int[] { 120, 122 });
                                        eventDateOffsets.put("Film Festival", new int[] { 150, 158 });
                                        eventDateOffsets.put("Cherry Festival", new int[] { 35, 37 });
                                        eventDateOffsets.put("Camel Festival", new int[] { 90, 93 });
                                        eventDateOffsets.put("Sahara Marathon", new int[] { 7, 9 });
                                        eventDateOffsets.put("Imilchil Marriage", new int[] { 125, 127 });
                                        eventDateOffsets.put("Tan-Tan Moussem", new int[] { 42, 48 });
                                        eventDateOffsets.put("Cedar Festival", new int[] { 52, 54 });
                                        eventDateOffsets.put("Kitesurf World Cup", new int[] { 110, 115 });
                                        eventDateOffsets.put("FICAM Meknes", new int[] { 20, 25 });

                                        for (Map.Entry<String, int[]> entry : eventDateOffsets.entrySet()) {
                                                String evName = entry.getKey();
                                                int[] offsets = entry.getValue();
                                                eventRepository.findAll().stream()
                                                        .filter(ev -> evName.equals(ev.getNom()))
                                                        .findFirst()
                                                        .ifPresent(ev -> {
                                                                ev.setDateDebut(LocalDateTime.now().plusDays(offsets[0]));
                                                                ev.setDateFin(LocalDateTime.now().plusDays(offsets[1]));
                                                                eventRepository.save(ev);
                                                        });
                                        }
                                        logger.info("Event dates updated to future 2026 dates.");
                                }

                                /*
                                 * =======================
                                 * 3. CREATE EVENTS
                                 * =======================
                                 */
                                // Removed count check to allow adding new events to existing ones
                                {
                                        // Helper to find destination by name
                                        java.util.function.Function<String, Destination> findDest = (
                                                        name) -> destinationRepository.findAll().stream()
                                                                        .filter(d -> d.getNom().contains(name)
                                                                                        || d.getType().contains(name))
                                                                        .findFirst()
                                                                        .orElse(null);
                                        Destination rabat = findDest.apply("Rabat");
                                        Destination agadir = findDest.apply("Agadir");
                                        Destination fes = findDest.apply("Fes");
                                        Destination kelaat = findDest.apply("Kelaat Mgouna");
                                        Destination tangier = findDest.apply("Tangier");
                                        Destination marrakech = findDest.apply("Jemaa el-Fnaa");
                                        Destination sefrou = findDest.apply("Sefrou");
                                        Destination guelmim = findDest.apply("Guelmim");
                                        Destination laayoune = findDest.apply("Laayoune");
                                        Destination imilchil = findDest.apply("Imilchil");

                                        // 2. Mawazine
                                        if (rabat != null) {
                                                createEvent("Mawazine",
                                                                "Festival international de musique.",
                                                                LocalDateTime.of(2026, 6, 21, 10, 0),
                                                                LocalDateTime.of(2026, 6, 29, 23, 0), "Rabat",
                                                                rabat,
                                                                "https://www.nrjmaroc.com/sites/default/files/styles/wide/public/2024-07/crea-article-2024-07-08t101053.220.png?itok=jR0VX1zq", "MUSIC",
                                                                "Mawazine — Rythmes du Monde est né en 2001 sous l'impulsion de la Fondation Maroc Cultures comme un festival visant à ouvrir le Maroc sur les grandes scènes musicales mondiales. Depuis ses débuts modestes, il est devenu l'un des plus grands festivals de musique au monde en termes de fréquentation, accueillant chaque année plusieurs millions de spectateurs sur plusieurs scènes gratuites à Rabat. Ce festival symbolise l'ouverture culturelle du Maroc et son ambition de se positionner comme un carrefour de cultures entre l'Afrique, le monde arabe et l'Occident. Au fil des éditions, Mawazine a accueilli des artistes légendaires comme Rihanna, Stevie Wonder et Elton John, faisant de la capitale chérifienne une scène musicale internationale de premier rang.");
                                        }

                                        // 3. Timitar
                                        if (agadir != null) {
                                                createEvent("Timitar", "Festival de la culture amazighe.",
                                                                LocalDateTime.of(2026, 7, 5, 10, 0),
                                                                LocalDateTime.of(2026, 7, 7, 23, 0), "Agadir",
                                                                agadir,
                                                                "https://femmesdumaroc.com/wp-content/uploads/2015/10/186722735.jpg", "CULTURAL",
                                                                "Timitar, qui signifie \"signes\" en tamazight, est né en 2004 à Agadir pour célébrer la richesse de la culture amazighe et sa place au cœur de l'identité marocaine. Créé par l'association Souss Culture, il est devenu l'un des rendez-vous culturels majeurs du pays, réunissant des artistes berbères du Maroc, d'Algérie, de Libye et de la diaspora mondiale. Ce festival incarne la renaissance culturelle amazighe portée par la consécration constitutionnelle de la langue tamazight en 2011. Il honore les musiques du Souss, de l'Atlas et du désert, rendant hommage à des artistes emblématiques comme Izenzaren, Biyoull et Ammouri Mbarek.");
                                        }

                                        // 4. Fes Sacred Music
                                        if (fes != null) {
                                                createEvent("Fes Sacred Music", "Musique spirituelle.",
                                                                LocalDateTime.of(2026, 5, 17, 10, 0),
                                                                LocalDateTime.of(2026, 5, 25, 23, 0), "Fes",
                                                                fes,
                                                                "https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?auto=format&fit=crop&q=80&w=2000", "MUSIC",
                                                                "Le Festival de Fès des Musiques Sacrées du Monde a été fondé en 1994 par Faouzi Skali, intellectuel soufi et chercheur, avec la conviction que la musique spirituelle peut être un puissant vecteur de paix et de dialogue entre les civilisations. Organisé dans le cadre unique de la ville impériale de Fès, berceau du soufisme marocain, il réunit chaque année des mystiques, des musiciens et des penseurs de toutes les traditions religieuses — islam, christianisme, judaïsme, bouddhisme, hindouisme. C'est un festival de l'âme qui transforme les jardins et les palais de Fès en espaces de méditation collective. Il est aujourd'hui reconnu comme l'un des festivals de musique les plus importants au monde.");
                                        }

                                        // 5. Rose Festival
                                        if (kelaat != null) {
                                                createEvent("Rose Festival", "Récolte des roses.",
                                                                LocalDateTime.of(2026, 5, 3, 10, 0),
                                                                LocalDateTime.of(2026, 5, 6, 23, 0), "Kelaat Mgouna",
                                                                kelaat,
                                                                "https://moroccoshinydays.com/wp-content/uploads/2022/04/rose-festival-Morocco-.png", "TRADITIONAL",
                                                                "Le Festival des Roses de Kelâat M'Gouna est une célébration annuelle qui honore la floraison des rosiers de Damas (Rosa damascena), cultivés dans la vallée du Dadès depuis des siècles. La tradition raconte que ces précieux rosiers furent rapportés de Syrie par des pèlerins de retour de La Mecque, s'implantant durablement dans les jardins amazighs de la vallée. Chaque printemps, quand les roses s'épanouissent en un tapis parfumé rose et rouge, les habitants les récoltent à l'aube pour extraire la précieuse eau de rose et l'huile essentielle exportées dans le monde entier. Le festival célèbre ce savoir-faire ancestral avec des défilés, des spectacles folkloriques, l'élection de la Reine des Roses et des soirées musicales unissant tradition et modernité.");
                                        }

                                        // 6. Tanjazz
                                        if (tangier != null) {
                                                createEvent("Tanjazz", "Festival de jazz.",
                                                                LocalDateTime.of(2026, 9, 12, 10, 0),
                                                                LocalDateTime.of(2026, 9, 14, 23, 0), "Tangier",
                                                                tangier,
                                                                "https://images.unsplash.com/photo-1511192336575-5a79af67a629?auto=format&fit=crop&q=80&w=2000", "MUSIC",
                                                                "Tanjazz est né en 2000 à Tanger, ville carrefour entre l'Europe et l'Afrique, bridgehead culturel par excellence qui a inspiré des générations d'artistes, d'écrivains et de musiciens du monde entier. Le festival célèbre le jazz et ses dérivés — blues, soul, world music — dans une ville qui a toujours été un melting-pot d'influences méditerranéennes, africaines et atlantiques. Tanger, qui a accueilli des figures comme Paul Bowles et Jimi Hendrix, offre un cadre romantique en bord de mer pour des concerts dans des rues pavées, des jardins et sur le front de mer. Tanjazz est devenu le symbole musical de la renaissance culturelle de Tanger comme métropole du nord du Maroc.");
                                        }

                                        // 7. Film Festival
                                        if (marrakech != null) {
                                                createEvent("Film Festival",
                                                                "Festival international du film.",
                                                                LocalDateTime.of(2026, 11, 24, 10, 0),
                                                                LocalDateTime.of(2026, 12, 2, 23, 0), "Jemaa el-Fnaa",
                                                                marrakech,
                                                                "https://www.hrw.org/sites/default/files/styles/embed_xxl/public/media_2024/03/202403film_fest_presser.JPG?itok=94ARRmtp", "FESTIVAL",
                                                                "Le Festival International du Film de Marrakech (FIFM) a été fondé en 2001 sous le haut patronage du Roi Mohammed VI dans le but de faire de Marrakech une capitale mondiale du cinéma. Organisé chaque année dans la Ville Ocre, il réunit des réalisateurs, acteurs et producteurs des cinq continents dans le décor unique des palaces et de la place Jemaa el-Fnaa. Le festival décerne l'Étoile d'Or à des films d'exception et rend hommage à des légendes du cinéma comme Martin Scorsese, Clint Eastwood et Francis Ford Coppola. Il contribue au développement d'une industrie cinématographique marocaine dynamique et à la promotion de Marrakech comme destination culturelle de classe mondiale.");
                                        }

                                        // 8. Cherry Festival
                                        if (sefrou != null) {
                                                createEvent("Cherry Festival", "Récolte des cerises.",
                                                                LocalDateTime.of(2026, 6, 7, 10, 0),
                                                                LocalDateTime.of(2026, 6, 9, 23, 0), "Sefrou",
                                                                sefrou,
                                                                "https://www.awesomemitten.com/wp-content/uploads/2015/07/Cherry-Festival.png", "FESTIVAL",
                                                                "Le Festival des Cerises de Sefrou est l'une des plus anciennes célébrations agricoles du Maroc, organisée depuis 1920 pour coïncider avec la maturité des cerisiers qui entourent la ville jardin au pied du Moyen Atlas. Sefrou, surnommée la \"ville jardin\" en raison de ses vergers luxurians irrigués par les sources de la rivière Aggaï, a toujours été un grenier de fruits et de légumes de la région de Fès. Durant le festival, la ville élabore une Reine des Cerises, organise des défilés folkloriques berbères, des concerts de musique andalouse et des marchés artisanaux qui rappellent la richesse du vivre-ensemble multiculturel qui a longtemps caractérisé Sefrou, ancienne ville de cohabitation entre Amazighes, Arabes et Juifs marocains.");
                                        }

                                        // 9. Camel Festival
                                        if (guelmim != null) {
                                                createEvent("Camel Festival", "Héritage nomade.",
                                                                LocalDateTime.of(2026, 8, 10, 10, 0),
                                                                LocalDateTime.of(2026, 8, 13, 23, 0), "Guelmim",
                                                                guelmim,
                                                                "https://images.hindustantimes.com/rf/image_size_960x540/HT/p2/2018/01/14/Pictures/_c52e8e54-f8e2-11e7-9cc5-99c3d5c09a90.jpg", "TRADITIONAL",
                                                                "Le Festival du Chameau de Guelmim est une célébration de l'héritage nomade saharien qui se tient dans la \"Porte du Sahara\", carrefour historique des caravanes transsahariennes depuis des millénaires. Le chameau, surnommé le \"vaisseau du désert\", est au cœur de la culture hassanie et des tribus nomades du Sahara occidental. Le festival met en lumière les chameaux de course, les chameaux de monte et les arts équestres sahariens à travers des courses spectaculaires, des expositions et des démonstrations de fantasia. C'est aussi une célébration de la musique gnaoua, des poésies hassanies et des danses traditionnelles qui transmettent aux jeunes générations l'âme profonde du désert marocain.");
                                        }

                                        // 10. Sahara Marathon
                                        if (laayoune != null) {
                                                createEvent("Sahara Marathon", "Marathon.",
                                                                LocalDateTime.of(2026, 2, 20, 10, 0),
                                                                LocalDateTime.of(2026, 2, 22, 23, 0), "Laayoune",
                                                                laayoune,
                                                                "https://d2goauph7ju525.cloudfront.net/wp-content/uploads/2019/04/Runners-fly-across-the-Saraha-Desert-during-the-2019-Marathon-des-Sables_JOSUEFPHOTO_DSC9566-750.jpg", "FESTIVAL",
                                                                "Le Marathon du Sahara organisé à Laayoune célèbre la solidarité et l'endurance humaine dans l'un des environnements les plus exigeants de la planète : les immensités arides du Sahara marocain. Inspiré du célèbre Marathon des Sables, cet événement réunit des coureurs du monde entier qui bravent les dunes, les vents chauds et les températures extrêmes pour repousser leurs limites physiques et mentales. Le marathon est aussi un acte de solidarité : une partie des recettes est systematiquement reversée à des associations locales qui soutiennent les populations sahraouies. Courir dans ces paysages infinis de sable doré, c'est vivre une expérience spirituelle et humaine unique au cœur du grand désert atlantique.");
                                        }

                                        // 11. Imilchil Marriage
                                        if (imilchil != null) {
                                                createEvent("Imilchil Marriage",
                                                                "Festival traditionnel.",
                                                                LocalDateTime.of(2026, 9, 15, 10, 0),
                                                                LocalDateTime.of(2026, 9, 17, 23, 0), "Imilchil",
                                                                imilchil,
                                                                "https://www.awesomemitten.com/wp-content/uploads/2015/07/Cherry-Festival.png", "TRADITIONAL",
                                                                "Le Moussem des Fiançailles d'Imilchil, aussi appelé Moussem de Had Imilchil, est un festival nuptial unique au monde ancré dans la légende tragique de Tislit et Isli, deux jeunes amants issus de tribus ennemies de l'Aït Haddidou dont les larmes auraient donné naissance aux lacs jumeaux du Haut Atlas. Pour commémorer cet amour impossible, les tribus berbères décidèrent d'organiser chaque automne un grand rassemblement où les jeunes hommes et femmes celibataires pouvaient se rencontrer librement et choisir leur futur époux ou épouse, transcendant ainsi les rivalités tribales. Ce moussem unique perpétue encore aujourd'hui les traditions vestimentaires, musicales et sociales des Aït Haddidou et réunit des milliers de participants autour d'un rituel de fiançailles collectif au cœur des montagnes sauvages de l'Atlas.");
                                        }

                                        // 12. Tan-Tan Moussem
                                        Destination guelmim_dest = findDest.apply("Guelmim");
                                        if (guelmim_dest != null) {
                                                createEvent("Tan-Tan Moussem",
                                                                "Patrimoine nomade reconnu par l'UNESCO.",
                                                                LocalDateTime.of(2026, 6, 12, 10, 0),
                                                                LocalDateTime.of(2026, 6, 18, 23, 0), "Tan-Tan",
                                                                guelmim_dest,
                                                                "https://aujourdhui.ma/wp-content/uploads/2017/05/Moussem-de-Tan-Tan.jpg", "TRADITIONAL",
                                                                "Le Moussem de Tan-Tan est l'un des plus grands rassemblements nomades au monde, classé en 2005 par l'UNESCO comme chef-d'oeuvre du patrimoine oral et immatériel de l'humanité. Organisé à Tan-Tan, ville-porte entre le Maroc et la Mauritanie, il réunit chaque deux ans des dizaines de milliers de représentants des tribus nomades sahraouies venues de tout le Sahara atlantique. Ce moussem traditionnel perpétue les traditions du nomadisme hassani : les courses de chameaux, la fantasia, la poésie orale hassanie (lghna), la fabrication de tentes traditionnelles et les rites de chefferie tribale. C'est un témoignage vivant et vibrant de la culture nomade du grand Sahara que Tan-Tan entend préserver pour les générations futures.");
                                        }

                                        // 13. Ifrane Cedar Festival
                                        Destination ifrane = findDest.apply("Ifrane");
                                        if (ifrane != null) {
                                                createEvent("Cedar Festival",
                                                                "Célébration de la nature au Moyen Atlas.",
                                                                LocalDateTime.of(2026, 7, 10, 10, 0),
                                                                LocalDateTime.of(2026, 7, 12, 23, 0), "Ifrane",
                                                                ifrane,
                                                                "https://images.unsplash.com/photo-1441974231531-c6227db76b6e?auto=format&fit=crop&q=80&w=2000", "FESTIVAL",
                                                                "Le Festival du Cèdre d'Ifrane célèbre la forêt de cèdres du Moyen Atlas, l'un des écosystèmes forestiers les plus précieux d'Afrique du Nord, refuges de l'emblématique macaque de Barbarie. Ifrane, surnommée la \"Suisse du Maroc\" pour ses paysages alpins enneigés, est le gardien naturel de ces forêts millénaires dont certains arbres, comme le légendaire Cèdre Gouraud, ont plus de 800 ans. Le festival sensibilise les visiteurs et les jeunes marocains à la conservation de cet écosystème menacé par le réchauffement climatique et les activités humaines, tout en célébrant la beauté unique du Moyen Atlas à travers des randonnées guidées, des expositions scientifiques et des animations culturelles amazighes.");
                                        }

                                        // 14. Dakhla Kitesurf World Cup
                                        Destination dakhla = findDest.apply("Dakhla");
                                        if (dakhla != null) {
                                                createEvent("Kitesurf World Cup",
                                                                "Compétition internationale de kitesurf.",
                                                                LocalDateTime.of(2026, 10, 15, 10, 0),
                                                                LocalDateTime.of(2026, 10, 20, 23, 0), "Dakhla Lagoon",
                                                                dakhla,
                                                                "https://www.planetkitesurfholidays.com/blog/wp-content/uploads/sites/2/2017/05/spain-tarifa-kitesurf-worldtour.jpg", "FESTIVAL",
                                                                "La Coupe du Monde de Kitesurf de Dakhla est l'un des événements sportifs nautiques les plus spectaculaires au monde, organisé dans la lagune de Dakhla, un site naturel exceptionnel formé par une péninsule de 40 km baignée par les eaux turquoise de l'Atlantique. Dakhla, souffle constant de l'Alizé qui souffle sans relâche sur la lagune, est reconnue depuis les années 2000 comme l'un des meilleurs spots de kitesurf et de windsurf de la planète. Cette compétition réunit l'élite mondiale de la discipline pour des performances acrobatiques stupéfiantes sur un plan d'eau d'une beauté à couper le souffle. La Coupe du Monde symbolise aussi la transformation réussie de Dakhla en destination sportive et touristique internationale de tout premier plan.");
                                        }

                                        // 15. Meknes International Animation Film Festival (FICAM)
                                        Destination meknes = findDest.apply("Meknes");
                                        if (meknes != null) {
                                                createEvent("FICAM Meknes",
                                                                "Festival international du cinéma d'animation.",
                                                                LocalDateTime.of(2026, 3, 1, 10, 0),
                                                                LocalDateTime.of(2026, 3, 6, 23, 0), "Meknes",
                                                                meknes,
                                                                "https://images.unsplash.com/photo-1724640779282-389a3ac31730?auto=format&fit=crop&q=80&w=2000", "CULTURAL",
                                                                "Le Festival International du Cinéma d'Animation de Meknès (FICAM) est le seul festival africain entièrement dédié au cinéma d'animation et est devenu un rendez-vous incontournable pour les professionnels et amateurs du 7ème art animé. Créé dans la ville impériale de Meknès, l'une des quatre capitales historiques du Maroc, le FICAM réunit chaque année des studios, des réalisateurs et des étudiants du monde entier pour des projections, des masterclasses et des ateliers de création. Il a pour vocation de stimuler l'émergence d'une industrie marocaine et africaine de l'animation, encourageant les jeunes talents à raconter leurs histoires avec les outils numériques contemporains tout en puisant dans la richesse des traditions visuelles et narratives du monde arabe et berbère.");
                                        }
                                }

                                logger.info("Data Initialization Completed Successfully");

                        } catch (Exception e) {
                                logger.error("Error during data initialization", e);
                        }
                };

        }

        private Destination createDestination(String name, String description, String city, String category, Double lat,
                        Double lon, String imageUrl, String historicalDescription) {
                Destination existing = destinationRepository.findAll().stream()
                                .filter(d -> name.equals(d.getNom()))
                                .findFirst()
                                .orElse(null);
                if (existing != null) {
                        existing.setDescription(description);
                        existing.setHistoire(historicalDescription);
                        destinationRepository.save(existing);
                        return null; // Don't create if already exists
                }
                Destination d = new Destination();
                d.setNom(name);
                d.setDescription(description);
                d.setHistoire(historicalDescription);
                d.setType(city); // Mapping city to 'type'
                d.setCategorie(category);
                d.setLatitude(lat);
                d.setLongitude(lon);

                if (imageUrl != null) {
                        Media m = Media.builder()
                                        .url(imageUrl)
                                        .type("IMAGE")
                                        .destination(d)
                                        .build();
                        d.getMedias().add(m);
                }
                return d;
        }

        private void createEvent(String name, String desc, LocalDateTime start,
                        LocalDateTime end, String lieu, Destination dest, String imgUrl, String type, String historique) {
                EvenementCulturel e = eventRepository.findAll().stream()
                                .filter(ev -> name.equals(ev.getNom()))
                                .findFirst()
                                .orElse(EvenementCulturel.builder().build());

                e.setNom(name);
                e.setDescription(desc + "\n\n" + historique);
                e.setDateDebut(start);
                e.setDateFin(end);
                e.setLieu(lieu);
                e.setDestination(dest);
                e.setTypeEvenement(type);
                e.setImageUrl(imgUrl);

                eventRepository.save(e);
        }
}
