use Text::CSV_XS;

use DBD::SQLite;
use DBI qw(:sql_types);

my $csv = Text::CSV_XS->new( { binary => 1} ) or
	die "cannot use CSV: ".Text::CSV->error_diag();

use constant NAME => 1;
use constant TYPE => 3;
use constant CLASS => 4;
use constant CROSS_STREETS => 13;
use constant ADDRESS1 => 14;
use constant ADDRESS2 => 15;
use constant CITY => 16;
use constant STATE => 17;
use constant ZIP => 18;
use constant LAT => 19;
use constant LON => 20;
use constant FACILITIES => 22;

# first row is fields
# row 1..N is data
my @rows;
open my $fh, "<:encoding(utf8)", "parks.csv" or die "unable to open parks.csv";

my %facilities = {};

# amenities - map what we have to these terms
#  Picnicking
#  Space
#  Path/Trail
#  Nature
#  Restroom
#  Fountain
#  Playground
#  Skate Park
#  Sports
#  Lake
#  Dog Park
#  Food
#  Other

sub term_categories {
	my $term = shift;
	my @terms = ();
	
	if( $term =~ /picnic/i ) {
		push @terms, "Picnicking";
	}
	
	if( $term =~ /bik/i ) {
		push @terms, "Biking";
	}
	
	if( $term =~ /hik/i or $term =~ /walk/i ) {
		push @terms, "Hiking";
	}
	
	if( $term =~ /lake/i or $term =~ /river/i ) {
		push @terms, "Water";
	}
	
	if( $term =~ /playground/i ) {
		push @terms, "Playground";
	}
	
	if( $term =~ /natur/i ) {
		push @terms, "Nature";
	}
	
	if( $term =~ /basketball/i or 
		$term =~ /golf/i or 
		$term =~ /tennis/i or 
		$term =~ /skate/i or 
		$term =~ /soccer/i or 
		$term =~ /field/i or 
		$term =~ /rugby/i or 
		$term =~ /bocce/i or 
		$term =~ /football/i or 
		$term =~ /softball/i or 
		$term =~ /volleyball/i or 
		$term =~ /baseball/i ) {
		push @terms, "Sports";
	}
	
	return @terms;
}

print("{ \"parks: [\n");

while( my $row = $csv->getline($fh) ) {
	if($row->[NAME] ne "") {

		my $name = $row->[NAME];
		my $type = $row->[TYPE];
		my $class = $row->[CLASS];
		my $crossStreets = $row->[CROSS_STREETS];
		my $addr1 = $row->[ADDRESS1];
		my $addr2 = $row->[ADDRESS2];
		my $city = $row->[CITY];
		my $state = $row->[STATE];
		my $lat = $row->[LAT] + 0.0;
		my $lon = $row->[LON] + 0.0;
		my $facilities = $row->[FACILITIES];

		print("\t{\"name\" : \"$name\", \n");
		print("\t\"type\" : \"$type\", \n");
		print("\t\"class\" : \"$class\", \n");
		print("\t\"address\" : \"$address\", \n");
		print("\t\"city\" : \"$city\", \n");
		print("\t\"state\" : \"$state\", \n");
		print("\t\"lat\" : $lat, \n");
		print("\t\"lon\" : $lon, \n");
		print("\t\"facilities\" : \"$facilities\", \n");
						
		# split up facilities and build $facilities{} hash
		my @facilityTerms = split(",", $facilities);
		my @termsToAdd = ();
		my %addedTerms = {};
		foreach my $term (@facilityTerms) {
		
			$term =~ s/^\s+|\s+$//g;	
			my $amenityId = 0;
			my @termsToAdd = term_categories($term);
			
			foreach my $trm (@termsToAdd) {
#				print("   checking $trm\n");
				if( undef eq $facilities{$trm} ) {
#					print("   adding $trm\n");
					# insert term into AMENITIES table
					# retrieve ID
					# add term to facilities hash with ID as value
					$facilities{$trm} = $amenityId;
				}
				else {
#					print("   fetching $trm\n");
					# look up ID from facilities hash with term
					$amenityId = $facilities{$trm};
				}
				
				if( undef eq $addedTerms{$trm} ) {
					# insert into amenitiesInParks
#					print("   addng tag $trm\n");
					
					$addedTerms{$trm} = 1;
				}
			}			
		}
		
		print("\t\"tags\":[");
		foreach my $term in keys(%addedTerms) {
			print("\"$term\", ");
		}
		print("]\n");
	}
}

# now dump the facilities to make sure we get the hash right
