  dst="/Users/chant/src/af/at_mono/trunk/dependency_reports/"
  timestamp=$(date -u +%s);
  package=$(dart pub deps | head -n 10 | grep -v 'SDK' | head -n 1 | cut -d' ' -f1 | tr -d '[:space:]');
  filename="./${timestamp}_${package}_report.txt"
  echo "running in package: $package"
  dart pub outdated | tee "$filename"
  dart analyze | tee "$filename"
  echo "copying $filename to $dst"
  mv $filename "$dst"
